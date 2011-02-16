require 'eventmachine'

module EM
  module Tycoon
    module Protocol
      class Parser
        include EM::Deferrable
        attr_reader :result,:bytes_parsed,:message
        attr_accessor :buffer
        
        # Create a new Parser deferrable, using the specified initial data and optional timeout specified in seconds
        def initialize(data=nil,timeout=0)
          self.buffer = buffer
          @bytes_parsed = 0
          timeout(timeout) if timeout > 0
          @message = nil
          parse_chunk(data) if data
        end
        
        def parse_chunk(data)
          @message ||= Message.message_for(data)
          
          return 0
        end
        
      end
    end
  end
end