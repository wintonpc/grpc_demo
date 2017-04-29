require 'pb/restaurant_pb'

module Cookbook
  def get_recipe(req, _)
    case req.name
    when 'cherry pie'
      recipe = Restaurant::Recipe.new(ingredients: ['flour', 'eggs', 'sugar', 'butter', 'cherries'])
      Restaurant::RecipeResponse.new(recipe: recipe)
    else
      raise "I don't have a recipe for '#{req.name}'"
    end
  end
end
