# Generated by the protocol buffer compiler.  DO NOT EDIT!
# source: restaurant.proto

require 'google/protobuf'

Google::Protobuf::DescriptorPool.generated_pool.build do
  add_message "restaurant.MixRequest" do
    repeated :ingredients, :string, 1
  end
  add_message "restaurant.MixResponse" do
    optional :description, :string, 1
  end
  add_message "restaurant.RecipeRequest" do
    optional :name, :string, 1
  end
  add_message "restaurant.RecipeResponse" do
    repeated :ingredients, :string, 1
  end
  add_message "restaurant.IngredientRequest" do
    optional :name, :string, 1
  end
  add_message "restaurant.IngredientResponse" do
    optional :description, :string, 1
  end
end

module Restaurant
  MixRequest = Google::Protobuf::DescriptorPool.generated_pool.lookup("restaurant.MixRequest").msgclass
  MixResponse = Google::Protobuf::DescriptorPool.generated_pool.lookup("restaurant.MixResponse").msgclass
  RecipeRequest = Google::Protobuf::DescriptorPool.generated_pool.lookup("restaurant.RecipeRequest").msgclass
  RecipeResponse = Google::Protobuf::DescriptorPool.generated_pool.lookup("restaurant.RecipeResponse").msgclass
  IngredientRequest = Google::Protobuf::DescriptorPool.generated_pool.lookup("restaurant.IngredientRequest").msgclass
  IngredientResponse = Google::Protobuf::DescriptorPool.generated_pool.lookup("restaurant.IngredientResponse").msgclass
end
