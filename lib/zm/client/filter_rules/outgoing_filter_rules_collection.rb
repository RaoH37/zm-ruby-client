# frozen_string_literal: true

module Zm
  module Client
    # collection of outgoing filter rules
    class OutgoingFilterRulesCollection < FilterRulesCollection
      private

      def make_query
        @parent.sacc.invoke(build_query)
      end

      def build_query
        SoapElement.mail(SoapMailConstants::GET_OUTGOING_FILTER_RULES_REQUEST)
      end
    end
  end
end
