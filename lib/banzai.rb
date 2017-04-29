module Banzai
  def start_workflow(name, *args)
    Rambda.apply(Capabilities.workflows[name], *args, make_workflow_env)
  end

  def define_workflow
    code = yield
    Rambda.eval(code, base_workflow_env)
  end

  private

  def base_workflow_env
    @base_workflow_env ||= begin
      env = Rambda::Env.new
      register_grpc_procs(env)
      env
    end
  end

  def make_workflow_env
    Rambda::Env.new(base_workflow_env)
  end

  def register_grpc_procs(env)
    code = <<EOD
(set! get-service
  (lambda (name)
    (ruby-call-proc "|x| Capabilities.services[x]" name)))
EOD
    Rambda.eval(code, env)
  end

  extend self
end
