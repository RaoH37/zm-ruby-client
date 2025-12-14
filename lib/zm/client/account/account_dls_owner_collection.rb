# frozen_string_literal: true

module Zm
  module Client
    # Collection Account dls membership
    class AccountDlsOwnerCollection < Base::ObjectsCollection
      def initialize(parent)
        @parent = parent
      end

      def make_query
        @parent.sac.invoke(build_query)
      end

      def build_query
        jsns = {
          query: "(zimbraACE=#{@parent.id} usr ownDistList)",
          types: SearchType::DL
        }

        SoapElement.admin(SoapAdminConstants::SEARCH_DIRECTORY_REQUEST)
                   .add_attributes(jsns)
      end

      private

      def build_response
        DistributionListsBuilder.new(@parent, make_query).make
      end
    end
  end
end
