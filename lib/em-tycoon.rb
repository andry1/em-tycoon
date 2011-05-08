require 'eventmachine'
require_relative 'em/tycoon'
require_relative 'em/tycoon/protocol/message'
['error', 'get','set','remove', 'play_script'].each do |x|
  require_relative "em/tycoon/protocol/binary/#{x}_message"
end
