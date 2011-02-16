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
          PARSE_PHASES=EM::Tycoon::Protocol::Message::PARSE_PHASES+[:header,:keys_and_values]
          HEADER_UNPACK_FORMATS=%w(n N N)
          
          def initialize(data={},opts={})
            super(:get,data)
            @key_fmt = String.new
            @value_fmt = String.new
            @xts = Array.new
            @db_idxs = Array.new
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

          def parse_chunk(data)
            return 0 unless data && data.bytesize > 0
            msg_hsh = {}
            bytes_parsed = 0
            case parse_phase
            when :magic,:item_count
              @magic, @item_count = data.unpack("CN")
              @parse_phase = :header
              @bytes_expected += HEADER_BYTES_PER_RECORD*item_count
              bytes_parsed = 5
            when :header
              unpack_fmt = HEADER_UNPACK_FORMATS.inject("") {|fmt,part| fmt << "#{part}#{item_count}"}
              unpack_fmt << "H16"*item_count
              header = data.unpack(unpack_fmt)
              @db_idxs = []
              @xts = []
              @key_sizes = []
              @value_sizes = []
              key_fmt = String.new
              value_fmt = String.new
              item_count.times do |x|
                @db_idxs << header[x]
                @key_sizes << header[x+item_count]
                @value_sizes << header[x+(item_count*2)]
                @xts << header[x+(item_count*3)].to_i(16)
                @key_fmt << "a#{@key_sizes.last}"
                @value_fmt << "a#{@value_sizes.last}"
              end
              @bytes_expected += (keysize+valuesize)
              bytes_parsed = (item_count*HEADER_BYTES_PER_RECORD)
              @parse_phase = :keys_and_values
            when :keys_and_values
              keys_and_values = data.unpack(@key_fmt+@value_fmt)
              @data = {}
              item_count.times do |x|
                xt = @xts.shift
                @data[keys_and_values[x]] = {
                  :dbidx => @db_idxs.shift,
                  :value => keys_and_values[x+item_count],
                  :xt => (xt == NO_EXPIRATION_TIME) ? nil : Time.at(xt)
                }
              end
              bytes_parsed = (keysize+valuesize)
              @parse_phase = :done
            end
            return bytes_parsed
          end
          
          def keysize
            @key_sizes.inject {|sum,x| sum += x}
          end
          
          def valuesize
            @value_sizes.inject {|sum,x| sum += x}
          end
          
        end
      end
    end
  end
end