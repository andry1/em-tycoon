require 'eventmachine'

module EM
  # EventMachine Kyoto Tycoon Driver
  # Uses Kyoto Tycoon's binary protocol for increased efficiency (see "Binary Protocol" at http://fallabs.com/kyototycoon/spex.html#protocol)
  module Tycoon
  
    DEFAULT_OPTS = {:host => '127.0.0.1', :port => 1978}
  
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
      end
      
      def unbind
      end
      
      # Use KT binary protocol "set_bulk" command to set keys and values passed in the data argument,
      # with the option to pass an optional expiration time by specifying it in the value, in the following format:
      # {
      #    "my_key1"          => "my value for my_key1",
      #    "my_key2"          => "my value for my_key2",
      #    "my_key3_with_60s_xt"  => {:value => "my value for my_key3_with_60s_xt", :xt => 60}
      # }
      # on completion, the callback block will be called (if provided) with the number of records stored as returned
      # by Kyoto Tycoon.  If no callback is specified, the no-reply option will be passed to Kyoto Tycoon
      def set(data={},&cb)
        begin
          msg = Protocol::Message.generate(:set, data, {:no_reply => !(block_given?)})
          send_data(msg.data)
          @jobs << DefaultDeferrable.new if block_given?
        rescue Exception => e
          yield 0 if block_given?
        end
      end
      
      def get(keys=[],&cb)
        raise ArgumentError.new("No block given") unless block_given?
        msg = Protocol::Message.generate(:get, keys)
        send_data(msg.data)
        @jobs << DefaultDeferrable.new
      end
      
      def remove(keys=[],&cb)
        msg = Protocol::Message.generate(:remove, keys)
        send_data(msg.data)
        @jobs << DefaultDeferrable.new if block_given?
      end
      
    end
    
  end
end