# frozen_string_literal: true

module Zm
  module Client
    # class factory [filter rules]
    class FilterRulesBuilder < Base::ObjectsBuilder
      def initialize(parent, json)
        super(parent, json)
        @json_item_key = :filterRules
      end

      def make
        return [] if json_items.nil?

        json_items.first[:filterRule].map do |entry|
          FilterRuleJsnsInitializer.create(@parent, entry)
        end
      end
    end
  end
end
