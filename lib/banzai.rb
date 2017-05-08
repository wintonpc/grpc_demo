require 'securerandom'
require 'oj'
require 'gateways/workflow_gateway'
require 'gateways/kv_gateway'
require 'zlib'
require 'pp'
require 'interop'
require 'marshaller'

class Banzai
  def initialize(wf_gateway=WorkflowGateway.new, kv_gateway=KVGateway.new)
    @wf_gateway = wf_gateway
    @kv_gateway = kv_gateway
  end

  def start_workflow(name, *args)
    id = "#{name}-#{SecureRandom.hex(4)}"
    puts "Starting workflow #{id}"
    observer = Observer.new(id, @wf_gateway, @kv_gateway)
    Capabilities.register_workflows
    env = Banzai.make_workflow_env
    Rambda.apply(env.look_up(name), *args, env, observer: observer, vm_id: 'root')
  end

  def resume_workflow(wfid)
    puts "Resuming workflow #{wfid}"
    bucket = 'wfstates'
    key = Banzai.skey(wfid, 'root')
    value = @kv_gateway.fetch(bucket, key)
    if value
      h = Banzai.load_state(value)
      state = h[:state]
      async_exprs = h[:async_exprs]
      observer = Observer.new(wfid, @wf_gateway, @kv_gateway)
      # TODO: resume in reverse spawn order, so waiter threads have an actual thread to wait on.
      # Or, block resume until all threads are started.
      async_exprs.each do |ae|
        ae.mutex = Mutex.new
        ae_key = Banzai.skey(wfid, ae.vm_id)
        if !ae.done
          raw_state = @kv_gateway.fetch(bucket, ae_key)
          if raw_state.nil?
            puts "No saved state for AsyncExpr #{ae.proc.env.look_up(:x)}; spawning fresh"
            Rambda::BuiltIn.spawn_async(ae, observer)
          else
            puts "Found saved state for #{ae.proc.env.look_up(:x)}; resuming"
            ae_state = Banzai.load_state(raw_state)[:state]
            Rambda::BuiltIn.resume_async(ae, ae_state, observer)
          end
        else
          puts 'Nothing to do for completed AsyncExpr'
        end
      end
      Rambda::VM.resume(state, observer: observer, vm_id: 'root')
    else
      puts "Workflow #{wfid} already completed"
    end
  end

  def cancel_workflow(wfid)
    puts "Cancelling workflow #{wfid}"
    bucket = 'wfstates'
    key = wfid
    @kv_gateway.delete(bucket, key)
    # probably should notify someone too...
  end

  def self.define_workflow
    code = yield
    Rambda.eval(code, base_workflow_env)
  end

  def self.dump_state(s)
    # Base64.encode64(Zlib::Deflate.deflate(Oj.dump(state, mode: :object, circular: true))
    # Base64.encode64(Marshal.dump(s))
    # Oj.dump(s, mode: :object, circular: true)
    Marshaller.dump(s)
  end

  def self.load_state(x)
    # Oj.load(Zlib::Inflate.inflate(Base64.decode64(value)), mode: :object, circular: true)
    # Marshal.load(Base64.decode64(x))
    # Oj.load(x, mode: :object, circular: true)
    Marshaller.load(x)
  end

  class Observer
    def initialize(wfid, wf_gateway, kv_gateway)
      @wfid = wfid
      @wf_gateway = wf_gateway
      @kv_gateway = kv_gateway
      @last_store = nil
    end

    def started(vm_id)
      puts "Running VM #{vm_id}"
    end

    def returned(vm_id, state)
      if true # @last_store.nil? || (Time.now - @last_store) > 0.5
        @last_store = Time.now
        bucket  = 'wfstates'
        key     = Banzai.skey(@wfid, vm_id)
        dumped_state = Banzai.dump_state(state)
        # puts dumped_state
        @kv_gateway.store(bucket, key, dumped_state)
      end
    end

    def halted(vm_id)
      bucket = 'wfstates'
      key = Banzai.skey(@wfid, vm_id)
      @kv_gateway.delete(bucket, key)
    end
  end

  def self.skey(wfid, vmid)
    "#{wfid}/#{vmid}"
  end

  private

  def self.base_workflow_env
    @base_workflow_env ||= begin
      env = Rambda::Env.new
      register_grpc_procs(env)
      env
    end
  end

  def self.make_workflow_env
    Rambda::Env.new(base_workflow_env)
  end

  def self.register_grpc_procs(env)
    code = <<EOD
(set! get-service
  (lambda (name)
    (ruby-call-proc "|x| Interop::ServiceShim.new(x)" name)))

(define (make-proto class-name attrs)
  (ruby-call-proc (++ "|attrs| " class-name ".new(attrs)") attrs))

(define-syntax define-proto
  (lambda (stx)
    (let* ([name (caadr stx)]
           [class-name (caaddr stx)]
           [attr-names (cdadr stx)]
           [maker-name (string->symbol (++ "make-" name))])
      `(begin
         (define (,maker-name attrs)
           (make-proto ,class-name attrs))
         (define ,name (list ,class-name ,maker-name (quote ,attr-names)))))))

(define-syntax define-rpc
  (lambda (stx)
    (let* ([proc-name (caadr stx)]
           [formals (cdadr stx)]
           [rpc-info (caddr stx)]
           [service-name (car rpc-info)]
           [method (cadr rpc-info)]
           [request-proto (caddr rpc-info)]
           [attr-stx (cons 'make-map (flatmap (lambda (n) (list `(quote ,n) n)) formals))])
      `(define (,proc-name ,@formals)
         (puts (++ ',proc-name " " (join " " (list->vector (list ,@formals)))))
         (let* ([proto ,request-proto]
                [maker (cadr proto)])
           (,method (get-service ',service-name) (maker ,attr-stx)))))))
EOD
    Rambda.eval(code, env)
  end
end
