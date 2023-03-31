# frozen_string_literal: true

module Zm
  module Client
    # class for initialize license
    class LicenseJsnsInitializer
      class << self
        def create(parent, json)
          item = License.new(parent)

          json[:attr].each do |a|
            item.instance_variable_set(Utils.arrow_name(a[:name]), a[:_content])
          end

          item
        end
      end
    end
  end
end
