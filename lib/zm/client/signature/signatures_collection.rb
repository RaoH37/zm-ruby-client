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
        @parent.sacc.jsns_request(:GetSignaturesRequest, @parent.token, nil, SoapAccountConnector::ACCOUNTSPACE)
      end
    end
  end
end
