# frozen_string_literal: true

module Zm
  module Client
    # class for initialize license
    class LicenseJsnsInitializer
      class << self
        def create(parent, json)
          License.new(parent).tap do |item|
            json[:attr].each do |a|
              setter = "#{a.delete(:name)}="
              value = a.dig(:maxLimit, :_content) || a.delete(:_content)

              if item.respond_to?(setter)
                item.send(setter, value)
              end
            end
          end
        end
      end
    end
  end
end
