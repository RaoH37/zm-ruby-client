module Zm
  module Client
    class MessagesBuilder < Base::ObjectsBuilder
      def initialize(account, json)
        @account = account
        @json = json
      end
    end
  end
end