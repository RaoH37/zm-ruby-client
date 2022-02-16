# frozen_string_literal: true

module Zm
  module Client
    # class factory [servers]
    class ServersBuilder < Base::ObjectsBuilder
      def initialize(parent, json)
        super(parent, json)
        @child_class = Server
        @json_item_key = :server
      end
    end
  end
end
