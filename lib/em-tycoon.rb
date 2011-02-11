require 'eventmachine'
require_relative 'em/tycoon'
require_relative 'em/tycoon/protocol/message'
['get','set','remove'].each do |x|
  require_relative "em/tycoon/protocol/binary/#{x}_message"
end
