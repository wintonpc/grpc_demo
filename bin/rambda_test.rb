#!/usr/bin/env ruby

this_dir = File.expand_path(File.dirname(__FILE__))
lib_dir = File.join(this_dir, '../lib')
pb_dir = File.join(lib_dir, 'pb')
$LOAD_PATH.unshift(lib_dir) unless $LOAD_PATH.include?(lib_dir)
$LOAD_PATH.unshift(pb_dir) unless $LOAD_PATH.include?(pb_dir)

require 'grpc'
require 'restaurant_services_pb'
require 'rambda'

SERVICES = {
    cookbook: Restaurant::Cookbook::Stub.new('localhost:50051', :this_channel_is_insecure)
}


def workflows
  @workflows ||= {
      bake: Rambda.eval(begin
                          <<EOD
(set! make-cookbook-request
  (lambda (name)
    (ruby-call-proc "|x| Restaurant::RecipeRequest.new(name: x)" name)))  

(set! bake
  (lambda (recipe-name)
    (begin
      (set! cookbook (get-service 'cookbook))
      (set! cb-request (make-cookbook-request recipe-name))
      (set! recipe (.recipe (.get_recipe cookbook cb-request)))
      (ruby-call-proc "|x| puts x" (.ingredients recipe)))))
EOD
                        end, base_workflow_env)
  }
end

def main
  start_workflow(:bake, 'cherry pie')
end

def start_workflow(name, *args)
  Rambda.apply(workflows[name], *args, make_workflow_env)
end

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
    (ruby-call-proc "|x| SERVICES[x]" name)))
EOD
  Rambda.eval(code, env)
end

main
