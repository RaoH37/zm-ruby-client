module Zm
  module Client
    class MessagesCollection < Base::ObjectsCollection
      def initialize(parent)
        @parent = parent
      end
    end
  end
end