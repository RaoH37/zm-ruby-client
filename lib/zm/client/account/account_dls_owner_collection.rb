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
        jsns = {
          query: "(zimbraACE=#{@parent.id} usr ownDistList)",
          types: SearchType::DL
        }

        soap_request = SoapElement.admin(SoapAdminConstants::SEARCH_DIRECTORY_REQUEST)
        soap_request.add_attributes(jsns)
        @parent.sac.invoke(soap_request)
      end

      def build_response
        DistributionListsBuilder.new(@parent, make_query).make
      end
    end
  end
end
