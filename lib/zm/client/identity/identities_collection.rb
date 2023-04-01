# frozen_string_literal: true

module Zm
  module Client
    # collection account identities
    class IdentitiesCollection < Base::AccountObjectsCollection
      def initialize(parent)
        @child_class = Identity
        @builder_class = IdentitiesBuilder
        super(parent)
      end

      private

      def make_query
        @parent.sacc.jsns_request(:GetIdentitiesRequest, @parent.token, nil, SoapAccountConnector::ACCOUNTSPACE)
      end
    end
  end
end
