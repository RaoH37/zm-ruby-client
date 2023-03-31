# frozen_string_literal: true

module Zm
  module Client
    # class factory [shares]
    class ShareBuilder < Base::ObjectsBuilder
      def initialize(parent, json)
        super(parent, json)
        @child_class = Share
        @json_item_key = :share
      end
    end
  end
end
