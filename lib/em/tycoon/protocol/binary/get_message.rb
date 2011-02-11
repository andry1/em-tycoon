module EM
  module Tycoon
    module Protocol  
      module Binary
        class GetMessage < EM::Tycoon::Protocol::Message
          def initialize(type,data,opts={})
            super(:get,data)
            generate_get_array(data)
          end
          
          def generate_get_array(data)
            data = [data.to_s] unless data.kind_of?(Array)
            msg_array = [MAGIC[:get], 0, data.length]
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