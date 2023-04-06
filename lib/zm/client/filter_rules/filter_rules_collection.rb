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
        @parent.sacc.jsns_request(:GetFilterRulesRequest, @parent.token, nil)
      end
    end
  end
end
