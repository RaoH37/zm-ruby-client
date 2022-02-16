# frozen_string_literal: true

module Zm
  module Client
    # class factory [accounts]
    class AccountsBuilder < Base::ObjectsBuilder
      def initialize(parent, json)
        super(parent, json)
        @child_class = Account
        @json_item_key = :account
      end

      def make
        return [] if json_items.nil?

        json_items.map do |entry|
          AccountJsnsInitializer.create(@parent, entry)
        end
      end
    end
  end
end
