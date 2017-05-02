require 'pb/restaurant_pb'

module SousChef
  def prepare(req, _)
    puts "SousChef received request for #{req.name}"
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
    sleep(1)
    Restaurant::IngredientResponse.new(description: desc)
  end
end
