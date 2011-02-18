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
        MSG_TYPES=MAGIC.invert
        FLAGS = {:no_reply => 0x01}
        DEFAULT_OPTS = {
          :no_reply => false
        }
        NO_EXPIRATION_TIME = 0x7FFFFFFFFFFFFFFF
        PARSE_PHASES=[:magic,:item_count]
        NO_XT_HEX="7#{'F'*15}"
        KV_PACK_FMT="nNNH*a*a*"
  
        attr_reader :bytes_expected,:parsed,:buffer,:parse_phase
        # The human-readable symbol version of the KT message type, as defined in the keys of Message::MAGIC
        attr_accessor :type
        # "Magic" number header from KT message, indicating message type
        attr_reader :magic
        # Number of items/KV pairs contained in KT message
        attr_reader :item_count
        # Total size, in bytes, of all key data contained in KT message
        attr_reader :keysize
        # Total size, in bytes, of all value data contained in KT message
        attr_reader :valuesize
        # The data payload of the KT message, which can either be empty, contain a hash of KV pairs, or
        # a list of keys
        attr_reader :data
        
        # Create a new KT message object to parse a response from KT or to serialize one to send,
        # type indicates the message type being created, as defined by the keys of Message::MAGIC
        # (e.g. :set, :get, etc.), and the optional data parameter can be used to specify the initial
        # contents of the message, specific to the message type
        def initialize(type,data=nil)
          self.class.check_msg_type(type)
          self.type = type
          @data = data
          @bytes_per_record = 0
          @bytes_expected = 5
          @keysize = @valuesize = 0
          @parsed = false
          @buffer = String.new
          @parse_phase = PARSE_PHASES.first
        end
        
        def type=(t)
          self.class.check_msg_type(t)
          @type = t.downcase.to_sym
          @magic = MAGIC[@type]
          return @type
        end
        
        # Parse an arbitrary blob of data, possibly containing an entire message, possibly part of it, possibly more than 1
        # returns the number of bytes from the buffer that were actually parsed and updates the #bytes_expected
        # property accordingly
        def parse(data)
          return 0 unless data && data.bytesize > 0
          if data.bytesize < @bytes_expected
            @buffer << data
            @bytes_expected -= data.bytesize
            return data.bytesize
          else
            @buffer << data[0..@bytes_expected]
            bytes_parsed = parse_chunk(@buffer)
            return 0 if bytes_parsed == 0 # This is an error
            @bytes_expected -= bytes_parsed
            @buffer = String.new
            if @bytes_expected == 0
              @parsed = true
            elsif (data.bytesize-bytes_parsed) > 0
              bytes_parsed += parse(data[bytes_parsed..-1])
            end
            return bytes_parsed 
          end
        end
        
        # Parse a Kyoto Tycoon binary protocol message part into this Message instance, returning the number
        # of bytes parsed.  Default implementation supports standard magic+hits or just magic (in case of error message)
        # messages     
        def parse_chunk(data)
          return 0 if data.nil?
          return 0 unless data.bytesize == @bytes_expected
          bytes_parsed = 0
          if @bytes_expected > 1
            @magic,@item_count = data.unpack("CN")
            bytes_parsed = 5
          else
            @magic = data.unpack("C").first
            bytes_parsed = 1
          end
          @data = @item_count
          @parse_phase = :item_count
          return bytes_parsed
        end
              
        def parsed?
          @parsed
        end
        
        def [](key)
          @data[key]
        end
        
        class << self
          protected(:new)
          
          def message_for(data)
            msgtype = msg_type_for(data)
            raise ArgumentError.new("Unknown magic byte 0x#{('%02X' % data[0])}") unless msgtype
            Binary.const_get("#{msgtype.to_s.capitalize}Message").new(data)
          end
          
          def msg_type_for(data)
            magic = data.unpack("C").first
            MSG_TYPES[magic]
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