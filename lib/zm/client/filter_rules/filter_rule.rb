# frozen_string_literal: true

module Zm
  module Client
    # class account filter rule
    class FilterRule < Base::AccountObject
      attr_accessor :name, :active, :filterTests, :filterActions
    end
  end
end
