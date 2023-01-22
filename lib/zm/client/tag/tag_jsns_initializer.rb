# frozen_string_literal: true

module Zm
  module Client
    # class for initialize account tag
    class TagJsnsInitializer
      class << self
        def create(parent, json)
          item = Tag.new(parent)

          update(item, json)
        end

        def update(item, json)
          item.instance_variable_set(:@id, json[:id])
          item.instance_variable_set(:@name, json[:name])
          item.instance_variable_set(:@color, json[:color].to_i)
          item.instance_variable_set(:@rgb, json[:rgb])

          item
        end
      end
    end
  end
end
