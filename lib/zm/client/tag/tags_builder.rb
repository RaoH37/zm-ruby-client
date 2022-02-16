# frozen_string_literal: true

module Zm
  module Client
    # class factory [tags]
    class TagBuilder < Base::ObjectsBuilder
      def initialize(parent, json)
        super(parent, json)
        @child_class = Tag
        @json_item_key = :tag
      end

      def make
        return [] if json_items.nil?

        json_items.map do |entry|
          TagJsnsInitializer.create(@parent, entry)
        end
      end
    end
  end
end
