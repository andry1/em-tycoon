module EM
  module Tycoon
    module Protocol  
      module Binary
        class ErrorMessage < EM::Tycoon::Protocol::Message
          def initialize(data={},opts={})
            super(:error)
          end
        end
      end
    end
  end
end