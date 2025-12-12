# frozen_string_literal: true

module Zm
  module Client
    # class for initialize account search folder
    class SearchFolderJsnsInitializer
      class << self
        def create(parent, json)
          SearchFolder.new(parent).tap do |item|
            update(item, json)
          end
        end

        def update(item, json)
          item.id = json.delete(:id)
          item.name = json.delete(:name)

          item.uuid = json.delete(:uuid)
          item.deletable = json.delete(:deletable)
          item.absFolderPath = json.delete(:absFolderPath)
          item.l = json.delete(:l)
          item.luuid = json.delete(:luuid)
          item.color = json.delete(:color)
          item.rgb = json.delete(:rgb)
          item.rev = json.delete(:rev)
          item.ms = json.delete(:ms)
          item.webOfflineSyncDays = json.delete(:webOfflineSyncDays)
          item.activesyncdisabled = json.delete(:activesyncdisabled)
          item.query = json.delete(:query)
          item.sortBy = json.delete(:sortBy)
          item.types = json.delete(:types)

          item
        end
      end
    end
  end
end
