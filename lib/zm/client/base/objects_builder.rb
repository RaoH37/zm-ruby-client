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
          @json.dig(:Body, json_key, :hit)&.map { |s| s[:id] } || []
        end

        private

        def json_items
          return @json_items if defined? @json_items

          @json_items = @json[json_key][@json_item_key]
        end

        def json_key
          return @json_key if defined? @json_key

          @json_key = @json.keys.first
        end
      end
    end
  end
end
