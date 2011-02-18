module EM
  module Tycoon
    module Protocol
      module Binary
        class SetMessage < EM::Tycoon::Protocol::Message

          def initialize(data={},opts={})
            super(:set,data)
          end
          
          def self.generate(data,opts={})
            raise ArgumentError.new("Unsupported data type : #{data.class.name}") unless data.kind_of?(Hash)
            msg_array = [MAGIC[:set]]
            optflags = 0
            opts.each_pair do |optkey,optval|
               optflags |= FLAGS[optkey] if (FLAGS.has_key?(optkey) and (optval == true))
            end
            msg_array << optflags
            msg_array << data.keys.length
            data.each_pair do |key,value|
              xt = NO_XT_HEX
              if value.kind_of?(Hash)
                if value.has_key?(:xt)
                  xt = ("%016X" % (value[:xt].kind_of?(Time) ? (value[:xt] - Time.now).to_i : value[:xt].to_i))
                end
                value = value[:value]
              end
              msg_array << 0 # dbidx
              msg_array << key.bytesize
              msg_array << value.bytesize
              msg_array << xt
              msg_array << key
              msg_array << value
            end
            return msg_array.pack("CNN#{KV_PACK_FMT*data.keys.length}")
           end
           
        end 
      end     
    end
  end
end