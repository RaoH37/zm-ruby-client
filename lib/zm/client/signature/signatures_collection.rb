# frozen_string_literal: true

module Zm
  module Client
    # collection of signatures
    class SignaturesCollection < Base::AccountObjectsCollection
      def initialize(parent)
        @child_class = Signature
        @builder_class = SignaturesBuilder
        super
      end

      def make_query
        @parent.soap_connector.invoke(build_query)
      end

      def build_query
        SoapElement.account(SoapAccountConstants::GET_SIGNATURES_REQUEST)
      end
    end
  end
end
