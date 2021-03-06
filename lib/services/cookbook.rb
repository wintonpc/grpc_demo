require 'pb/restaurant_pb'

module Cookbook
  def get_recipe(req, _)
    puts "Cookbook received request for #{req.name}"
    case req.name
    when 'cherry pie'
      Restaurant::RecipeResponse.new(ingredients: ['flour', 'eggs', 'sugar', 'butter', 'cherries'])
    else
      raise "I don't have a recipe for '#{req.name}'"
    end
  end
end
