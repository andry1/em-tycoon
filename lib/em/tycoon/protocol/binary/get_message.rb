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
          HEADER_UNPACK_FORMAT="nNNH16"
          # Best I can figure it, Mikio is passing in 63 bits of 1s in set_bulk messages inside
          # his own utilities to force KT to detect an overflow of the _real_ max XT time (which is 40 bits of 1s)
          # and then returns that real max XT time in the get_bulk reply... I think
          NO_EXPIRATION_TIME_RESPONSE=0x000000ffffffffff
          def initialize(data={},opts={})
            super(:get,data)
            @key_fmt = String.new
            @value_fmt = String.new
            @xts = Array.new
            @db_idxs = Array.new
            @keys_parsed = 0
            @keysize = 0
            @valuesize = 0
            @dbidx = 0
            @xt = 0
          end
          
          def self.generate(data,opts={})
            data = [data.to_s] unless data.kind_of?(Array)
            msg_array = [MAGIC[:get], 0, data.length]
            data.each {|k|
              msg_array += [0, k.bytesize, k]
            }
            return msg_array.pack("CNN#{'nNa*'*data.length}")
          end

          def parse_chunk(data)
            return 0 unless data && data.bytesize > 0
            msg_hsh = {}
            bytes_parsed = 0
            case parse_phase
            when :magic,:item_count
              @magic, @item_count = data.unpack("CN")
              @parse_phase = :header
              @bytes_expected += HEADER_BYTES_PER_RECORD
              bytes_parsed = 5
              @data = Hash.new
            when :header
              @dbidx,@keysize,@valuesize,@xt = data.unpack(HEADER_UNPACK_FORMAT)
              @xt = @xt.to_i(16)
              @bytes_expected += (@keysize+@valuesize)
              bytes_parsed = HEADER_BYTES_PER_RECORD
              @parse_phase = :keys_and_values
            when :keys_and_values
              k,v = data.unpack("a#{@keysize}a#{@valuesize}")
              @data[k] = {
                :value => v,
                :dbidx => @dbidx,
                :xt => (@xt == NO_EXPIRATION_TIME_RESPONSE) ? nil : Time.at(@xt)
              }
              bytes_parsed = (@keysize+@valuesize)
              @keysize = 0
              @valuesize = 0
              @dbidx = 0
              @xt = nil
              if (@keys_parsed+=1) == item_count
                @parse_phase = :done
              else
                @parse_phase = :header
                @bytes_expected += HEADER_BYTES_PER_RECORD
              end
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