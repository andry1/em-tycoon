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
        NO_EXPIRATION_TIME = 0x7FFFFFFFFFFFFFFF
        
        attr_reader :type
        attr_reader :data
        attr_reader :min_message_length

        def initialize(type)
          self.class.check_msg_type(type)
          @type = type.downcase.to_sym
          @data = keys
          @min_message_length = 5
          @bytes_per_record = 0
        end
        
        def parsed?
          @parsed
        end
        
        def generate(opts={})
          return nil
        end
        
        class << self
          
          # Parse a Kyoto Tycoon binary protocol message header, returning an instance of the appropriate Message class          
          def parse(data)
            return nil if data.nil?
            return nil unless data.bytesize >= 1
            magic = data.unpack("C").first
            msgtype = MAGIC.invert[magic]
            raise ArgumentError.new("Unknown magic byte 0x#{('%02X' % magic)}") unless msgtype
            msg_klass = Binary.const_get("#{msgtype.to_s.capitalize}Message")
            return msg_klass.from_bytes(data)
          end
          
          def from_bytes(data)
            magic, hits = data.unpack("CN")
            return hits
          end
          
          def generate(type, data, opts={})
            check_msg_type(type)
            opts=DEFAULT_OPTS.merge(opts)
            Binary.const_get("#{type.to_s.capitalize}Message").generate(data,opts)
          end
        
          def check_msg_type(type)
            raise ArgumentError.new("Unknown message type #{type.inspect}") unless MAGIC.has_key?(type.downcase.to_sym)
          end          
        end
      end
    end
  end
end