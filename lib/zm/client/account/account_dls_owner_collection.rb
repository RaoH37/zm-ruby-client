# frozen_string_literal: true

module Zm
  module Client
    # Collection Account dls membership
    class AccountDlsOwnerCollection < Base::ObjectsCollection
      def initialize(parent)
        @parent = parent
      end

      private

      def make_query
        @parent.sac.search_directory("(zimbraACE=#{@parent.id} usr ownDistList)", SoapUtils::MAX_RESULT, nil, nil, nil, nil, nil, nil, SearchType::DL)
      end

      def build_response
        DistributionListsBuilder.new(@parent, make_query).make
      end
    end
  end
end
