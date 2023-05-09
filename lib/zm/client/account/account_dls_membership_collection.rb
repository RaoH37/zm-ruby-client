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
        # @parent.sac.get_account_membership(@parent.id, :id)

        soap_request = SoapElement.admin(SoapAdminConstants::GET_ACCOUNT_MEMBERSHIP_REQUEST)
        node_account = SoapElement.new('account', nil).add_attribute('by', 'id').add_content(@parent.id)
        soap_request.add_node(node_account)
        sac.invoke(soap_request)
      end

      def build_response
        DistributionListsBuilder.new(@parent, make_query).make
      end
    end
  end
end
