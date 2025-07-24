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

      def save!
        return false unless defined? @all

        soap_request = SoapElement.mail(SoapMailConstants::MODIFY_FILTER_RULES_REQUEST)
        node_rules = SoapElement.create(:filterRules).add_attribute(:filterRule, @all.map(&:to_h))
        soap_request.add_node(node_rules)
        @parent.sacc.invoke(soap_request)

        true
      end

      private

      def make_query
        soap_request = SoapElement.mail(SoapMailConstants::GET_FILTER_RULES_REQUEST)
        @parent.sacc.invoke(soap_request)
      end
    end
  end
end
