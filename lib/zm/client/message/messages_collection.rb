# frozen_string_literal: true

module Zm
  module Client
    # Collection Messages
    class MessagesCollection < Base::ObjectsCollection
      def initialize(parent)
        @parent = parent
      end
    end
  end
end
