# frozen_string_literal: true

module Zm
  module Client
    # class factory [messages]
    class MessagesBuilder < Base::ObjectsBuilder
      def initialize(account, json)
        @account = account
        @json = json
      end
    end
  end
end
