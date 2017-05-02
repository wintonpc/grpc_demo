require 'pb/restaurant_pb'

module Mixer
  def mix(req, _)
    puts "Mixer received request to mix #{req.ingredients.join(', ')}"
    sleep(1)
    Restaurant::MixResponse.new(description: "A conglomeration of #{req.ingredients.join(', ')}")
  end
end
