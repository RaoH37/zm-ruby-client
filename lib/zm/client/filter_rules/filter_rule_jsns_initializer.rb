# frozen_string_literal: true

module Zm
  module Client
    # class for initialize account filter rule
    class FilterRuleJsnsInitializer
      class << self
        def create(parent, json)
          item = FilterRule.new(parent)
          update(item, json)
        end

        def update(item, json)
          item.name = json[:name]
          item.active = json[:active]
          item.filterTests = json[:filterTests]
          item.filterActions = json[:filterActions]

          item
        end
      end
    end
  end
end
