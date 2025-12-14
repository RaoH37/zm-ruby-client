# frozen_string_literal: true

module Zm
  module Client
    # class factory [messages]
    class MessagesBuilder < Base::ObjectsBuilder
      def initialize(parent, json)
        super
        @json_item_key = :m
      end

      def make
        return [] if json_items.nil?

        json_items.map do |entry|
          MessageJsnsInitializer.create(@parent, entry)
        end
      end
    end
  end
end
