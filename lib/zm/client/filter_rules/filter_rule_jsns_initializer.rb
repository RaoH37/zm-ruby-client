# frozen_string_literal: true

module Zm
  module Client
    # class for initialize account filter rule
    class FilterRuleJsnsInitializer
      class << self
        def create(parent, json)
          FilterRule.new(parent).tap do |item|
            update(item, json)
          end
        end

        def update(item, json)
          item.name = json.delete(:name)
          item.active = json.delete(:active)
          item.filterTests = json.delete(:filterTests)
          item.filterActions = json.delete(:filterActions)

          item
        end
      end
    end
  end
end
