# frozen_string_literal: true

module Zm
  module Client
    # class factory [coses]
    class CosesBuilder < Base::ObjectsBuilder
      def initialize(parent, json)
        super(parent, json)
        @json_item_key = :cos
      end

      def make
        return [] if json_items.nil?

        json_items.map do |entry|
          CosJsnsInitializer.create(@parent, entry)
        end
      end
    end
  end
end
