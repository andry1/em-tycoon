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
            keysize = 0
            valuesize = 0
            keys = []
            values = []
            xts = []
            data.each_pair do |key,value|
               if value.kind_of?(Hash) and value.has_key?(:xt)
                 xts << ("%016X" % value[:xt].to_i)
                 raise ArgumentError("No value found for key : #{key}") unless value.has_key?(:value)
                 values << value[:value]
                 valuesize += value[:value].bytesize
               else
                 xts << "7#{'F'*15}"
                 values << value
                 valuesize += value.bytesize
               end
               keys << key
               keysize += key.bytesize
            end
            msg_array << keys.length
            msg_array += [0]*keys.length # Database idx
            msg_array << keysize
            msg_array << valuesize
            msg_array += xts
            msg_array += keys
            msg_array += values
            return msg_array.pack("CNN#{'n'*keys.length}NN#{'H*'*keys.length}#{'a*'*(keys.length*2)}")
           end
           
        end 
      end     
    end
  end
end