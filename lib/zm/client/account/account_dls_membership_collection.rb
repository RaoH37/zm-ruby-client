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
        soap_request = SoapElement.admin(SoapAdminConstants::GET_ACCOUNT_MEMBERSHIP_REQUEST)
        node_account = SoapElement.create(SoapConstants::ACCOUNT)
                                  .add_attribute(SoapConstants::BY, SoapConstants::ID)
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
