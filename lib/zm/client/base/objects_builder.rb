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

        def make
          return [] if json_items.nil?

          json_items.map do |entry|
            child = @child_class.new(@parent)
            child.init_from_json(entry)
            child
          end
        end

        private

        def json_key
          @json_key ||= @json[:Body].keys.first
        end
      end
    end
  end
end
