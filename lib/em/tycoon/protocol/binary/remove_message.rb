module EM
  module Tycoon
    module Protocol  
      module Binary
        class RemoveMessage < EM::Tycoon::Protocol::Message
          def initialize(type,data,opts={})
            super(:get,data)
            generate_remove_array(data,opts)
          end
          
          def generate_remove_array(data,opts={})
            data = [data.to_s] unless data.kind_of?(Array)
            msg_array = [MAGIC[:remove]]
            optflags = 0
            opts.each_pair do |optkey,optval|
               optflags |= FLAGS[optkey] if (FLAGS.has_key?(optkey) and (optval == true))
            end
            msg_array << optflags
            msg_array << data.length
            msg_array += ([0]*data.length)
            key_sizes = []
            keys = data.collect {|k| key_sizes << k.to_s.bytesize; k.to_s}
            msg_array += key_sizes
            msg_array += keys
            @data = msg_array.pack("CNN#{'n'*data.length}#{'N'*data.length}#{'a*'*data.length}")
            return self
          end
        end
      end
    end
  end
end