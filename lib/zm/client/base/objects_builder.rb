module Zm
  module Client
    module Base
      # Abstract Class Builder [object]
      class ObjectsBuilder
        def initialize(parent, json)
          @parent = parent
          @json = json
        end

        private

        def json_key
          @json_key ||= @json[:Body].keys.first
        end
      end
    end
  end
end
