#!/usr/bin/env ruby

this_dir = File.expand_path(File.dirname(__FILE__))
lib_dir = File.join(this_dir, '../lib')
pb_dir = File.join(lib_dir, 'pb')
$LOAD_PATH.unshift(lib_dir) unless $LOAD_PATH.include?(lib_dir)
$LOAD_PATH.unshift(pb_dir) unless $LOAD_PATH.include?(pb_dir)

require 'grpc'
require 'restaurant_services_pb'

def main
  cookbook = Restaurant::Cookbook::Stub.new('localhost:50051', :this_channel_is_insecure)
  recipe = cookbook.get_recipe(Restaurant::RecipeRequest.new(name: 'cherry pie')).recipe
  puts "Recipe: #{recipe.ingredients.join(', ')}"
end

main
