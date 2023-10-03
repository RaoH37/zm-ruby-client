# frozen_string_literal: true

module Zm
  module Client
    # Collection Account dls membership
    class AccountDlsMembershipCollection < Base::ObjectsCollection
      def initialize(parent)
        @parent = parent
      end

      private

      def make_query
        soap_request = SoapElement.admin(SoapAdminConstants::GET_ACCOUNT_MEMBERSHIP_REQUEST)
        node_account = SoapElement.create(SoapConstants::ACCOUNT).add_attribute(SoapConstants::BY, SoapConstants::ID).add_content(@parent.id)
        soap_request.add_node(node_account)
        sac.invoke(soap_request)
      end

      def build_response
        DistributionListsBuilder.new(@parent, make_query).make
      end
    end
  end
end
