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
        @parent.sac.get_distribution_list_membership(@parent.id, :id)
      end

      def build_response
        @all = make_query.dig(:Body, :GetDistributionListMembershipResponse, :dl) || []
        @all.map { |json| DlMembership.new(json[:name], json[:id], json[:via]) }
      end
    end
  end
end
