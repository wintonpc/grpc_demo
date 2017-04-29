#!/usr/bin/env ruby

Dir.chdir(File.dirname(__FILE__)) do
  system('grpc_tools_ruby_protoc -I ./protos --ruby_out=lib/pb --grpc_out=lib/pb ./protos/restaurant.proto')
end
