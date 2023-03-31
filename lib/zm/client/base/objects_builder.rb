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

        # TODO: supprimer cette méthode
        def make
          return [] if json_items.nil?

          json_items.map do |entry|
            child = @child_class.new(@parent)
            child.init_from_json(entry)
            child
          end
        end

        # TODO: remplacer root par json_items
        def ids
          root.map { |s| s[:id] }
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
