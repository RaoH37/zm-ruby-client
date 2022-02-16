# frozen_string_literal: true

module Zm
  module Client
    # class factory [aces]
    class AcesBuilder < Base::ObjectsBuilder
      def initialize(parent, json)
        super(parent, json)
        @child_class = Ace
        @json_item_key = :ace
      end

      def make
        return [] if json_items.nil?

        json_items.map do |entry|
          AceJsnsInitializer.create(@parent, entry)
        end
      end
    end
  end
end
