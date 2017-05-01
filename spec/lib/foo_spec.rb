require 'rspec'
require 'interop'
require 'capabilities'

module Restaurant
  class RecipeRequest
    def _dump(_level)
      puts 'marshaling with _dump'
      result = Marshal.dump([self.class.to_s, self.to_proto])
      puts 'done marshaling with _dump'
      result
    end
  end
end

describe 'My behaviour' do
  it 'should do something' do
    msg = Restaurant::RecipeRequest.new
    Marshal.dump(msg)
  end
end
