module EM
  module Tycoon
    module Protocol  
      module Binary
        class GetMessage < EM::Tycoon::Protocol::Message
          HEADER_BYTES_PER_RECORD = (
            2 + # (uint16_t): (iteration): the index of the target database.
            4 + # (uint32_t): (iteration): the size of the key.
            4 + # (uint32_t): (iteration): the size of the value.
            8   # (int64_t): (iteration): the expiration time.
          )
          HEADER_UNPACK_FORMATS=%w(n N N)
          
          def initialize(data={},opts={})
            super(:get,data)
          end
          
          def self.generate(data,opts={})
            data = [data.to_s] unless data.kind_of?(Array)
            msg_array = [MAGIC[:get], 0, data.length]
            msg_array += ([0]*data.length)
            key_sizes = []
            keys = data.collect {|k| key_sizes << k.to_s.bytesize; k.to_s}
            msg_array += key_sizes
            msg_array += keys
            return msg_array.pack("CNN#{'n'*data.length}#{'N'*data.length}#{'a*'*data.length}")
          end

          def parse_header(data)
            magic, hits = data.unpack("CN")
            return 5
          end

          def self.from_bytes(data)
            msg_hsh = {}
            magic, hits = data.unpack("CN")
            bytes_parsed = 5
            unpack_fmt = HEADER_UNPACK_FORMATS.inject("") {|fmt,part| fmt << "#{part}#{hits}"}
            unpack_fmt << "H16"*hits
            header_len = (hits*HEADER_BYTES_PER_RECORD)
            sizes_and_xts = data[bytes_parsed..(header_len+bytes_parsed)].unpack(unpack_fmt)
            bytes_parsed += header_len
            db_idxs = []
            xts = []
            key_fmt = String.new
            value_fmt = String.new
            hits.times do |x|
              db_idxs << sizes_and_xts[x]
              key_size = sizes_and_xts[x+hits]
              value_size = sizes_and_xts[x+(hits*2)]
              xts << sizes_and_xts[x+(hits*3)].to_i(16)
              key_fmt << "a#{key_size}"
              value_fmt << "a#{value_size}"
            end
            keys_and_values = data[bytes_parsed..-1].unpack(key_fmt+value_fmt)
            hits.times do |x|
              xt = xts.shift
              msg_hsh[keys_and_values[x]] = {
                :dbidx => db_idxs.shift,
                :value => keys_and_values[x+hits],
                :xt => (xt == NO_EXPIRATION_TIME) ? nil : Time.at(xt)
              }
            end
            return msg_hsh
          end
        end
      end
    end
  end
end