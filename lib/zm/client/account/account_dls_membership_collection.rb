# frozen_string_literal: true

module Zm
  module Client
    # Collection Account dls membership
    class AccountDlsMembershipCollection < Base::ObjectsCollection
      def initialize(parent)
        @parent = parent
      end

      def make_query
        sac.invoke(build_query)
      end

      def build_query
        soap_request = SoapRequest::SoapElement.admin(Zm::SoapRequest::SoapAdminConstants::GET_ACCOUNT_MEMBERSHIP_REQUEST)
        node_account = SoapRequest::SoapElement.create(SoapRequest::SoapConstants::ACCOUNT)
                                  .add_attribute(SoapRequest::SoapConstants::BY, SoapRequest::SoapConstants::ID)
                                  .add_content(@parent.id)
        soap_request.add_node(node_account)
        soap_request
      end

      private

      def build_response
        DistributionListsBuilder.new(@parent, make_query).make
      end
    end
  end
end
