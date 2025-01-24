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
          item.cprop_inspect_map.keys.each do |k|
            next unless json[k]

            setter = :"#{k}="
            item.send(setter, json[k]) if item.respond_to?(setter)
          end

          item
        end
      end
    end
  end
end
