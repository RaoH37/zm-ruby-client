# frozen_string_literal: true

module Zm
  module Client
    # class factory [contacts]
    class ContactBuilder < Base::ObjectsBuilder
      def initialize(parent, json)
        super(parent, json)
        @child_class = Contact
        @json_item_key = :cn
      end
    end
  end
end
