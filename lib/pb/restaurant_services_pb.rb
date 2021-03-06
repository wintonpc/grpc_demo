# Generated by the protocol buffer compiler.  DO NOT EDIT!
# Source: restaurant.proto for package 'restaurant'

require 'grpc'
require 'restaurant_pb'

module Restaurant
  module Cookbook
    class Service

      include GRPC::GenericService

      self.marshal_class_method = :encode
      self.unmarshal_class_method = :decode
      self.service_name = 'restaurant.Cookbook'

      rpc :GetRecipe, RecipeRequest, RecipeResponse
    end

    Stub = Service.rpc_stub_class
  end
  module SousChef
    class Service

      include GRPC::GenericService

      self.marshal_class_method = :encode
      self.unmarshal_class_method = :decode
      self.service_name = 'restaurant.SousChef'

      rpc :Prepare, IngredientRequest, IngredientResponse
    end

    Stub = Service.rpc_stub_class
  end
  module Mixer
    class Service

      include GRPC::GenericService

      self.marshal_class_method = :encode
      self.unmarshal_class_method = :decode
      self.service_name = 'restaurant.Mixer'

      rpc :Mix, MixRequest, MixResponse
    end

    Stub = Service.rpc_stub_class
  end
end
