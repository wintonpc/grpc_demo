require 'pb/restaurant_pb'
require 'interop'

module Capabilities
  def services
    # host = '172.19.1.109:50051'
    host = '10.10.14.205:50051'
    @services ||= {
        cookbook: Restaurant::Cookbook::Stub.new(host, :this_channel_is_insecure),
        sous_chef: Restaurant::SousChef::Stub.new(host, :this_channel_is_insecure),
        mixer: Restaurant::Mixer::Stub.new(host, :this_channel_is_insecure),
    }
  end

  def register_workflows
    unless @registered_workflows
      @registered_workflows = true
      define_workflow_from_file('bake')
    end
  end

  private

  def define_workflow_from_file(name)
    Banzai.define_workflow { File.read(File.expand_path("../workflows/#{name}.ss", __FILE__)) }
  end

  extend self
end
