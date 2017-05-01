require 'pb/restaurant_pb'

module SousChef
  def prepare(req, _)
    sleep(1)
    desc =
        case req.name
        when 'flour' then 'a cup of flour'
        when 'eggs' then 'two whole eggs (cracked)'
        when 'sugar' then 'two cups of sugar'
        when 'butter' then 'one stick of butter (softened)'
        when 'cherries' then 'two pints of cherries'

        else
          raise "I don't know how to prepare '#{req.name}'"
        end
    ingredient = Restaurant::Ingredient.new(description: desc)
    Restaurant::IngredientResponse.new(ingredient: ingredient)
  end
end
