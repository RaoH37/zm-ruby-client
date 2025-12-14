# frozen_string_literal: true

module Zm
  module Client
    # class factory [filter rules]
    class FilterRulesBuilder < Base::ObjectsBuilder
      def initialize(parent, json)
        super
        @json_item_key = :filterRules
      end

      def make
        return [] if json_items.nil?

        rules = json_items.first[:filterRule]
        return [] if rules.nil?

        rules.map do |entry|
          FilterRuleJsnsInitializer.create(@parent, entry)
        end
      end
    end
  end
end
