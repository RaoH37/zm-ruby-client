# frozen_string_literal: true

module Zm
  module Client
    # class account tag
    class Tag < Base::Object
      include SoapRequest::RequestMethodsMailbox
      include MailboxItemConcern
      extend Relationship
      has_jsns_builder

      attr_accessor :name, :color, :rgb

      def create!
        rep = @parent.soap_connector.invoke(build_create)
        json = rep[:CreateTagResponse][:tag].first
        TagJsnsInitializer.update(self, json)
        id
      end
    end
  end
end
