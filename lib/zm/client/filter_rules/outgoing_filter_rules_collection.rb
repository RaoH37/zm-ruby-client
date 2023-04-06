# frozen_string_literal: true

module Zm
  module Client
    # collection of outgoing filter rules
    class OutgoingFilterRulesCollection < FilterRulesCollection
      private

      def make_query
        @parent.sacc.jsns_request(:GetOutgoingFilterRulesRequest, @parent.token, nil)
      end
    end
  end
end
