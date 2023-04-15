# frozen_string_literal: true

module Zm
  module Client
    # class factory [resources]
    class ResourcesBuilder < Base::ObjectsBuilder
      def initialize(parent, json)
        super(parent, json)
        @json_item_key = :calresource
      end

      def make
        return [] if json_items.nil?

        json_items.map do |entry|
          ResourceJsnsInitializer.create(@parent, entry)
        end
      end
    end
  end
end
