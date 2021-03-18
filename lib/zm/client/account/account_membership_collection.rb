# frozen_string_literal: true

module Zm
  module Client
    # Collection Account dls relation
    class AccountMembershipCollection < Base::ObjectsCollection
      def initialize(parent)
        @parent = parent
      end

      private

      def make_query
        @parent.sac.get_account_membership(@parent.id, :id)
      end

      def build_response
        DistributionListsBuilder.new(@parent, make_query).make
      end
    end
  end
end
