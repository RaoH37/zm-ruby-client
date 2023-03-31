# frozen_string_literal: true

module Zm
  module Client
    # collection account contacts
    class ContactsCollection < Base::AccountObjectsCollection
      def initialize(parent)
        @child_class = Contact
        @builder_class = ContactBuilder
        super(parent)
      end

      private

      def make_query
        @parent.sacc.get_all_contacts(@parent.token)
      end
    end
  end
end
