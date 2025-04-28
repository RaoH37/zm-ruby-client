# frozen_string_literal: true

module Zm
  module Client
    # collection of outgoing filter rules
    class OutgoingFilterRulesCollection < FilterRulesCollection
      private

      def make_query
        soap_request = SoapElement.mail(SoapMailConstants::GET_OUTGOING_FILTER_RULES_REQUEST)
        @parent.sacc.invoke(soap_request)
      end
    end
  end
end
