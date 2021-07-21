# frozen_string_literal: true

module Zm
  module Client
    # class factory [accounts]
    class AccountsBuilder < Base::ObjectsBuilder
      def initialize(parent, json)
        super(parent, json)
        @child_class = Account
      end

      private

      def json_items
        @json_items ||= @json[:Body][json_key][:account]
      end
    end
  end
end
