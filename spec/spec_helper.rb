begin
  require File.expand_path('../../.bundle/environment', File.dirname(__FILE__))
rescue LoadError
  require 'rubygems'
  require 'bundler'

  Bundler.setup(:default, :test)
end
require 'eventmachine'
require 'rspec'
require 'em-spec/rspec'
require 'child-process-manager'

RSpec.configure do |config|
  config.mock_with :mocha
end

$LOAD_PATH << File.dirname(__FILE__) + '/../lib'
require 'em-tycoon'

KT_OPTS={:host => "localhost", :port => 1979}