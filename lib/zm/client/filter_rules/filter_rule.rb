# frozen_string_literal: true

module Zm
  module Client
    # class account filter rule
    class FilterRule < Base::Object
      attr_accessor :name, :active, :filterTests, :filterActions

      def to_h
        {
          name: name,
          active: active,
          filterTests: filterTests,
          filterActions: filterActions
        }
      end
    end
  end
end
