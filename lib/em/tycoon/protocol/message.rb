module EM
  module Tycoon
    module Protocol
      
      # Represents a Kyoto Tycoon binary protocol message
      # See KT docs : http://fallabs.com/kyototycoon/spex.html#protocol
      class Message
        MAGIC={:set => 0xB8,
               :get => 0xBA,
               :remove => 0xB9,
               :replication => 0xB1,
               :error => 0xBF}
        FLAGS = {:no_reply => 0x01}
        DEFAULT_OPTS = {
          :no_reply => false
        }
        
        attr_reader :type
        attr_reader :data
        
        def initialize(type,data={})
          self.class.check_msg_type(type)
          @type = type.downcase.to_sym
          @data = data
        end
        
        class << self

          # Parse a Kyoto Tycoon binary protocol message, returning an instance of this Message class
          def parse(data)
          end
          
          def generate(type, data, opts={})
            check_msg_type(type)
            opts=DEFAULT_OPTS.merge(opts)
            Binary.const_get("#{type.to_s.capitalize}Message").new(type,data,opts)
          end
        
          def check_msg_type(type)
            raise ArgumentError.new("Unknown message type #{type.inspect}") unless MAGIC.has_key?(type.downcase.to_sym)
          end          
        end
      end
    end
  end
end