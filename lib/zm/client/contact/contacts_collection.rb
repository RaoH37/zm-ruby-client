# frozen_string_literal: true

module Zm
  module Client
    # collection account contacts
    class ContactsCollection < Base::AccountSearchObjectsCollection
      def initialize(parent)
        super
        @child_class = Contact
        @builder_class = ContactsBuilder
        @type = SoapRequest::SoapConstants::CONTACT
        @folder_ids = [FolderDefault::CONTACTS.id]
      end
    end
  end
end
