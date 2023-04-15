# frozen_string_literal: true

module Zm
  module Client
    module Base
      # Abstract Class Builder [object]
      class ObjectsBuilder
        def initialize(parent, json)
          @parent = parent
          @json = json
        end

        def ids
          @json[:Body][json_key][:hit]&.map { |s| s[:id] } || []
        end

        private

        def json_items
          @json_items ||= @json[:Body][json_key][@json_item_key]
        end

        def json_key
          @json_key ||= @json[:Body].keys.first
        end
      end
    end
  end
end
