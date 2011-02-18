module EM
  module Tycoon
    module Protocol  
      module Binary
        class RemoveMessage < EM::Tycoon::Protocol::Message

          def initialize(data=nil,opts={})
            super(:remove,data)
          end
          
          def self.generate(data,opts={})
            data = [data.to_s] unless data.kind_of?(Array)
            msg_array = [MAGIC[:remove]]
            optflags = 0
            opts.each_pair do |optkey,optval|
               optflags |= FLAGS[optkey] if (FLAGS.has_key?(optkey) and (optval == true))
            end
            msg_array << optflags
            msg_array << data.length
            data.each do |d|
              msg_array << 0 # dbidx
              msg_array << d.to_s.bytesize
              msg_array << d
            end
            return msg_array.pack("CNN#{'nNa*'*data.length}")
          end
        end
      end
    end
  end
end