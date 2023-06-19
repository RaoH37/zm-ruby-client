# frozen_string_literal: true

module Zm
  module Client
    # collection account identities
    class IdentitiesCollection < Base::AccountObjectsCollection
      def initialize(parent)
        @child_class = Identity
        @builder_class = IdentitiesBuilder
        super(parent)
      end

      private

      def make_query
        soap_request = SoapElement.account(SoapAccountConstants::GET_IDENTITIES_REQUEST)
        @parent.sacc.invoke(soap_request)
      end
    end
  end
end
