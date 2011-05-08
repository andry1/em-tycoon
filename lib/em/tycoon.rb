require 'eventmachine'
require_relative 'tycoon/protocol/parser'

module EM
  # EventMachine Kyoto Tycoon Driver
  # Uses Kyoto Tycoon's binary protocol for increased efficiency (see "Binary Protocol" at http://fallabs.com/kyototycoon/spex.html#protocol)
  # To get started:
  #
  #   tycoon = EM::Tycoon.connect(:host => 'localhost', :port => 1978)
  #   tycoon.get("key1","key2","key3") do |results|
  #     results.each_pair { |k,v| puts "#{k} = #{v[:value]}" }
  #   end
  #
  module Tycoon
    DEFAULT_OPTS = {:host => '127.0.0.1', :port => 1978}
    REQUEST_TIMEOUT = 2 # Timeout requests after 2 seconds
  
    # Connect to a Kyoto Tycoon host, supported options are:
    # * :host => host name or IP address of ktserver instance (default '127.0.0.1')
    # * :port => port ktserver is listening on (default 1978)
    def self.connect(options={})
      options = DEFAULT_OPTS.merge(options)
      EM.connect(options[:host], options[:port], Client)
    end
  
    # Kyoto Tycoon binary protocol handler
    class Client < EM::Connection
      
      def initialize
        super
      end
      
      def post_init
        @jobs = []
      end
    
      def receive_data(data)
        bytes_parsed = 0
        while @jobs.any? && (bytes_parsed < data.bytesize)
          bytes_parsed += @jobs.first.parse_chunk(data[bytes_parsed..-1])
          @jobs.shift if @jobs.first.message.parsed?
        end
      end
      
      def unbind
      end
      
      # Use KT binary protocol "set_bulk" command to set keys and values passed in the data argument,
      # with the option to pass an optional expiration time by specifying it in the value, in the following format:
      #
      # {
      #    "my_key1"          => "my value for my_key1",
      #    "my_key2"          => "my value for my_key2",
      #    "my_key3_with_60s_xt"  => {:value => "my value for my_key3_with_60s_xt", :xt => 60}
      # }
      #
      # Expiration times can be specified either as an integer representing the number of seconds the key should persist
      # after it is created, or as a Time object containing the absolute time at which the key should expire.
      #
      # On completion, the callback block will be called (if provided) with the number of records stored as returned
      # by Kyoto Tycoon, or nil on error.  If no callback is specified, the no-reply option will be passed to Kyoto Tycoon.
      # 
      def set(data={},&cb)
        msg = Protocol::Message.generate(:set, data, {:no_reply => !(block_given?)})
        if block_given?
          job = Protocol::Parser.new(REQUEST_TIMEOUT)
          job.callback { |result|
            cb.call(result) if block_given?
          }
          job.errback { |result|
            cb.call(nil) if block_given?
          }
          @jobs << job
          send_data(msg)
        end
      end
      
      # Use KT binary protocol "get_bulk" command to get values for the given keys
      # The callback will be called upon completion and passed a hash with the returned values and expirations
      # (see EM::Tycoon::Client#set), or nil on error
      def get(*keys,&cb)
        raise ArgumentError.new("No block given") unless block_given?
        msg = Protocol::Message.generate(:get, keys)
        job = Protocol::Parser.new(REQUEST_TIMEOUT)
        job.callback { |result|
          cb.call(result) if block_given?
        }
        job.errback { |result|
          cb.call(nil) if block_given?
        }
        @jobs << job
        send_data(msg)
      end
      
      # Use KT binary protocol "remove_bulk" command to remove the given keys
      # The callback will be called upon completion and passed the number of keys deleted, or nil on error
      def remove(keys=[],&cb)
        msg = Protocol::Message.generate(:remove, keys)
        if block_given?
          job = Protocol::Parser.new(REQUEST_TIMEOUT)
          job.callback { |result|
            cb.call(result) if block_given?
          }
          job.errback { |result|
            cb.call(nil) if block_given?
          }
          @jobs << job
          send_data(msg)
        end
      end
      
      # Use KT binary protocol "play_script" command to execute the script function passed in the script_name
      # argument, with the arguments passed in args
      # The callback will be called upon completion and passed a hash containing the key/value pairs returned
      # by the script (see EM::Tycoon::Client#set), or nil on error
      def play_script(script_name, args={}, &cb)
        msg = Protocol::Message.generate(:play_script, [script_name,args])
        if block_given?
          job = Protocol::Parser.new(REQUEST_TIMEOUT)
          job.callback { |result|
            cb.call(result) if block_given?
          }
          job.errback { |result|
            cb.call(nil) if block_given?
          }
          @jobs << job
          send_data(msg)
        end
      end
      
    end
    
  end
end