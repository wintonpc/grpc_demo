#!/usr/bin/env ruby

this_dir = File.expand_path(File.dirname(__FILE__))
lib_dir = File.join(this_dir, '../lib')
pb_dir = File.join(lib_dir, 'pb')
$LOAD_PATH.unshift(lib_dir) unless $LOAD_PATH.include?(lib_dir)
$LOAD_PATH.unshift(pb_dir) unless $LOAD_PATH.include?(pb_dir)

require 'grpc'
require 'restaurant_services_pb'
require 'rambda'
require 'capabilities'
require 'banzai'

def main

  if ARGV[0]
    wfid = ARGV[0]
    Banzai.new.resume_workflow(wfid)
  else
    Banzai.new.start_workflow(:bake, 'cherry pie')
  end
end

main
