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

      def make_query
        @parent.soap_connectorv.invoke(build_query)
      end

      def build_query
        SoapElement.mail(SoapMailConstants::GET_FILTER_RULES_REQUEST)
      end
    end
  end
end
