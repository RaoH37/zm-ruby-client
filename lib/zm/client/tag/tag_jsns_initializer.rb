# frozen_string_literal: true

module Zm
  module Client
    # class for initialize account tag
    class TagJsnsInitializer
      class << self
        def create(parent, json)
          Tag.new(parent).tap do |item|
            update(item, json)
          end
        end

        def update(item, json)
          item.id = json.delete(:id)
          item.name = json.delete(:name)
          item.color = json.delete(:color)
          item.rgb = json.delete(:rgb)

          item
        end
      end
    end
  end
end
