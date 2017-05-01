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
    Rambda.apply(env.look_up(name), *args, env, observer: observer)
  end

  def resume_workflow(wfid)
    puts "Resuming workflow #{wfid}"
    bucket           = 'wfstates'
    key              = wfid
    value = @kv_gateway.fetch(bucket, key)
    if value
      state = Banzai.load_state(value)
      observer = Observer.new(wfid, @wf_gateway, @kv_gateway)
      Rambda::VM.resume(state, observer: observer)
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
    end

    def returned(state)
      bucket  = 'wfstates'
      key     = @wfid
      dumped_state = Banzai.dump_state(state)
      # puts dumped_state
      @kv_gateway.store(bucket, key, dumped_state)
    end

    def halted
      bucket = 'wfstates'
      key = @wfid
      @kv_gateway.delete(bucket, key)
    end
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
EOD
    Rambda.eval(code, env)
  end
end
