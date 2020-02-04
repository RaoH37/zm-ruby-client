# frozen_string_literal: true

module Zm
  module Client
    # collection account contacts
    class ContactsCollection < Base::ObjectsCollection
      def initialize(parent)
        @parent = parent
      end

      def new
        contact = Contact.new(@parent)
        yield(contact) if block_given?
        contact
      end

      private

      def build_response
        rep = @parent.sacc.get_all_contacts(@parent.token)
        cb = ContactBuilder.new @parent, rep
        cb.make
      end
    end
  end
end
