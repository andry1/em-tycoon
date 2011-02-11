require 'rubygems'
require 'bundler'
require 'eventmachine'
require 'rspec'
require 'em-spec/rspec'

RSpec.configure do |config|
  config.mock_with :mocha
end

$LOAD_PATH << File.dirname(__FILE__) + '/../lib'
require 'em-tycoon'

KT_OPTS={:host => "localhost", :port => 1978}