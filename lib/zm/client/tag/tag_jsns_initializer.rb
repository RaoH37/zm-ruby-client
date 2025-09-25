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
          item.id = json[:id]
          item.name = json[:name]
          item.color = json[:color].to_i
          item.rgb = json[:rgb]

          item
        end
      end
    end
  end
end
