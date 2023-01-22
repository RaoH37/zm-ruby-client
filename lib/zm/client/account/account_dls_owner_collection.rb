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

        @parent.sac.search_directory(jsns)
      end

      def build_response
        DistributionListsBuilder.new(@parent, make_query).make
      end
    end
  end
end
