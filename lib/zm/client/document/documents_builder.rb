# frozen_string_literal: true

module Zm
  module Client
    # class factory [documents]
    class DocumentsBuilder < Base::ObjectsBuilder
      def initialize(parent, json)
        super(parent, json)
        @json_item_key = :doc
      end

      def make
        return [] if json_items.nil?

        json_items.map do |entry|
          DocumentJsnsInitializer.create(@parent, entry)
        end
      end
    end
  end
end
