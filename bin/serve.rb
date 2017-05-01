#!/usr/bin/env ruby

this_dir = File.expand_path(File.dirname(__FILE__))
lib_dir = File.join(this_dir, '../lib')
pb_dir = File.join(lib_dir, 'pb')
$LOAD_PATH.unshift(lib_dir) unless $LOAD_PATH.include?(lib_dir)
$LOAD_PATH.unshift(pb_dir) unless $LOAD_PATH.include?(pb_dir)

require 'grpc'
require 'restaurant_services_pb'
require 'services/cookbook'
require 'services/sous_chef'

class CookbookServer < Restaurant::Cookbook::Service
  include Cookbook
end

class SousChefServer < Restaurant::SousChef::Service
  include SousChef
end

def main
  s = GRPC::RpcServer.new
  s.add_http2_port('127.0.0.1:50051', :this_port_is_insecure)
  s.handle(CookbookServer)
  s.handle(SousChefServer)
  s.run_till_terminated
end

main
