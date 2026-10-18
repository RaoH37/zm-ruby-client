# frozen_string_literal: true

module Zm
  module Client
    DlMembership = Data.define(:name, :id, :via)

    # Collection distribution list dls membership
    class DlsMembershipCollection < Base::ObjectsCollection
      def initialize(parent)
        super()
        @parent = parent
      end

      def make_query
        sac.invoke(build_query)
      end

      def build_query
        soap_request = SoapRequest::SoapElement.admin(Zm::SoapRequest::SoapAdminConstants::GET_DISTRIBUTION_LIST_MEMBERSHIP_REQUEST)
        node_account = SoapRequest::SoapElement.create(SoapRequest::SoapConstants::ACCOUNT)
                                               .add_attribute(SoapRequest::SoapConstants::BY, SoapRequest::SoapConstants::ID)
                                               .add_content(@parent.id)
        soap_request.add_node(node_account)
        soap_request
      end

      private

      def build_response
        collection = make_query.dig(:Body, :GetDistributionListMembershipResponse, :dl) || []
        collection.map { |json| DlMembership.new(name: json[:name], id: json[:id], via: json[:via]) }
      end
    end
  end
end
