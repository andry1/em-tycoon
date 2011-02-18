require 'eventmachine'

module EM
  module Tycoon
    module Protocol
      class Parser
        include EM::Deferrable
        attr_reader :result,:bytes_parsed,:message
        attr_accessor :buffer
        
        # Create a new Parser deferrable, using the specified initial data and optional timeout specified in seconds
        def initialize(timeout=0)
          @bytes_parsed = 0
          timeout(timeout) if timeout > 0
          @message = nil
        end
        
        def parse_chunk(data)
          @message ||= Message.message_for(data)
          @bytes_parsed += @message.parse(data)
          @result = @message.data
          succeed(@message.data) if @message.parsed?
          return @bytes_parsed
        end
        
      end
    end
  end
end