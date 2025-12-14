# frozen_string_literal: true

module Zm
  module Client
    # class factory [servers]
    class ServersBuilder < Base::ObjectsBuilder
      def initialize(parent, json)
        super
        @json_item_key = :server
      end

      def make
        return [] if json_items.nil?

        json_items.map do |entry|
          ServerJsnsInitializer.create(@parent, entry)
        end
      end
    end
  end
end
