# frozen_string_literal: true

module Zm
  module Client
    # class factory [shares]
    class ShareBuilder < Base::ObjectsBuilder
      def initialize(parent, json)
        super(parent, json)
        @json_item_key = :share
      end

      def make
        return [] if json_items.nil?

        json_items.map do |entry|
          ShareJsnsInitializer.create(@parent, entry)
        end
      end
    end
  end
end
