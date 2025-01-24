# frozen_string_literal: true

module Zm
  module Client
    # class for initialize account search folder
    class SearchFolderJsnsInitializer
      class << self
        def create(parent, json)
          item = SearchFolder.new(parent)
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
