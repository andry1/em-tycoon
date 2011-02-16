module EM
  module Tycoon
    module Protocol  
      module Binary
        class ErrorMessage < EM::Tycoon::Protocol::Message
          def initialize(data={},opts={})
            super(:error)
            @bytes_expected = 1
          end
          
          def self.from_bytes(data=nil)
            return self.new
          end
        end
      end
    end
  end
end