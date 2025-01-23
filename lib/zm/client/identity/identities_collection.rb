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

      def make_query
        @parent.sacc.invoke(build_query)
      end

      def build_query
        SoapElement.account(SoapAccountConstants::GET_IDENTITIES_REQUEST)
      end
    end
  end
end
