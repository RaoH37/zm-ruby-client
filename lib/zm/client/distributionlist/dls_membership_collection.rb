# frozen_string_literal: true

module Zm
  module Client
    DlMembership = Struct.new(:name, :id, :via)

    class DlsMembershipCollection < Base::ObjectsCollection
      def initialize(parent)
        @parent = parent
      end

      private

      def make_query
        soap_request = SoapElement.admin(SoapAdminConstants::GET_DISTRIBUTION_LIST_MEMBERSHIP_REQUEST)
        node_account = SoapElement.create(SoapConstants::ACCOUNT).add_attribute(SoapConstants::BY, SoapConstants::ID).add_content(@parent.id)
        soap_request.add_node(node_account)
        sac.invoke(soap_request)
      end

      def build_response
        @all = make_query.dig(:Body, :GetDistributionListMembershipResponse, :dl) || []
        @all.map { |json| DlMembership.new(json[:name], json[:id], json[:via]) }
      end
    end
  end
end
