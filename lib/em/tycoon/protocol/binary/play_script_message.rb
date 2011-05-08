module EM
  module Tycoon
    module Protocol
      module Binary
        class PlayScriptMessage < EM::Tycoon::Protocol::Message
          KV_PACK_FMT="NNa*a*"
          HEADER_BYTES_PER_RECORD=8
          
          def initialize(data={},opts={})
            super(:play_script,data)
            @keys_parsed = 0
            @keysize = 0
            @valuesize = 0
          end
          
          def self.generate(data,opts={})
            raise ArgumentError.new("Unsupported data type : #{data.class.name}") unless data.kind_of?(Array)
            raise ArgumentError.new("Expected array of [<String>,<Hash>]") unless (data.length == 2) && data.first.kind_of?(String) && data.last.kind_of?(Hash)
            script_name = data.first
            args = data.last
            msg_array = [MAGIC[:play_script]]
            optflags = 0
            opts.each_pair do |optkey,optval|
               optflags |= FLAGS[optkey] if (FLAGS.has_key?(optkey) and (optval == true))
            end
            msg_array << optflags
            msg_array << script_name.bytesize
            msg_array << args.keys.length
            msg_array << script_name
            args.each_pair do |key,value|
              value = value
              msg_array << key.bytesize
              msg_array << value.bytesize
              msg_array << key.to_s
              msg_array << value.to_s
            end
            return msg_array.pack("CNNNa*#{KV_PACK_FMT*args.keys.length}")
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
                @keysize,@valuesize = data.unpack("NN")
                @bytes_expected += (@keysize+@valuesize)
                bytes_parsed = HEADER_BYTES_PER_RECORD
                @parse_phase = :keys_and_values
              when :keys_and_values
                k,v = data.unpack("a#{@keysize}a#{@valuesize}")
                @data[k] = {:value => v}
                bytes_parsed = (@keysize+@valuesize)
                @keysize = 0
                @valuesize = 0
                if (@keys_parsed+=1) == item_count
                  @parse_phase = :done
                else
                  @parse_phase = :header
                  @bytes_expected += HEADER_BYTES_PER_RECORD
                end
              end
              return bytes_parsed
            end
           
        end
      end
    end
  end
end