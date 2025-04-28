# frozen_string_literal: true

module Zm
  module Client
    # collection of signatures
    class SignaturesCollection < Base::AccountObjectsCollection
      def initialize(parent)
        @child_class = Signature
        @builder_class = SignaturesBuilder
        super(parent)
      end

      private

      def make_query
        soap_request = SoapElement.account(SoapAccountConstants::GET_SIGNATURES_REQUEST)
        @parent.sacc.invoke(soap_request)
      end
    end
  end
end
