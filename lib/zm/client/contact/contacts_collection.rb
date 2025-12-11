# frozen_string_literal: true

module Zm
  module Client
    # collection account contacts
    class ContactsCollection < Base::AccountSearchObjectsCollection
      def initialize(parent)
        super(parent)
        @child_class = Contact
        @builder_class = ContactBuilder
        @type = SoapConstants::CONTACT
        @folder_ids = [FolderDefault::CONTACTS[:id]]
        # super(parent)
      end

      # def folder(folder)
      #   return self unless folder.is_a?(Zm::Client::Folder)
      #
      #   folder_id(folder.id)
      # end
      #
      # def folder_id(folder_id)
      #   return self if @folder_id == folder_id
      #
      #   @folder_id = folder_id
      #   self
      # end

      # def make_query
      #   @parent.soap_connector.invoke(build_query)
      # end

      # def build_query
      #   jsns = @folder_id.nil? ? nil : { l: @folder_id }
      #   SoapElement.mail(SoapMailConstants::GET_CONTACTS_REQUEST).add_attributes(jsns)
      # end
    end
  end
end
