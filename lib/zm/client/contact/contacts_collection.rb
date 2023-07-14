# frozen_string_literal: true

module Zm
  module Client
    # collection account contacts
    class ContactsCollection < Base::AccountObjectsCollection
      def initialize(parent)
        @child_class = Contact
        @builder_class = ContactBuilder
        @folder_id = nil
        super(parent)
      end

      def folder(folder)
        return self unless folder.is_a?(Zm::Client::Folder)

        folder_id(folder.id)
      end

      def folder_id(folder_id)
        return self if @folder_id == folder_id

        @folder_id = folder_id
        self
      end

      private

      def make_query
        jsns = @folder_id.nil? ? nil : { l: @folder_id }
        soap_request = SoapElement.mail(SoapMailConstants::GET_CONTACTS_REQUEST).add_attributes(jsns)
        @parent.sacc.invoke(soap_request)
      end
    end
  end
end
