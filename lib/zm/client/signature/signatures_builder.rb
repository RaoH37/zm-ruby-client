# frozen_string_literal: true

module Zm
  module Client
    # class factory [signatures]
    class SignaturesBuilder < Base::ObjectsBuilder
      def initialize(parent, json)
        super(parent, json)
        @child_class = Signature
        @json_item_key = :signature
      end

      def make
        return [] if json_items.nil?

        json_items.map do |entry|
          SignatureJsnsInitializer.new(@parent, entry).create
        end
      end
    end
  end
end
