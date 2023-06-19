# frozen_string_literal: true

module Zm
  module Client
    # collection of filter rules
    class FilterRulesCollection < Base::AccountObjectsCollection
      def initialize(parent)
        @child_class = FilterRule
        @builder_class = FilterRulesBuilder
        super(parent)
      end

      private

      def make_query
        soap_request = SoapElement.mail(SoapMailConstants::GET_FILTER_RULES_REQUEST)
        @parent.sacc.invoke(soap_request)
      end
    end
  end
end
