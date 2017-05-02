require 'pb/restaurant_pb'

module Mixer
  def mix(req, _)
    puts 'Mixer received request'
    sleep(1)
    desc = "A conglomeration of #{req.ingredients.join(', ')} mixed with #{req.tool}"
    Restaurant::MixResponse.new(description: desc)
  end
end
