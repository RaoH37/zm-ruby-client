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
          item.id = json[:id].to_i
          item.name = json[:name]

          item.uuid = json[:uuid]
          item.deletable = json[:deletable]
          item.absFolderPath = json[:absFolderPath]
          item.l = json[:l].to_i
          item.luuid = json[:luuid]
          item.color = json[:color]
          item.rgb = json[:rgb]
          item.rev = json[:rev]
          item.ms = json[:ms]
          item.webOfflineSyncDays = json[:webOfflineSyncDays]
          item.activesyncdisabled = json[:activesyncdisabled]
          item.query = json[:query]
          item.sortBy = json[:sortBy]
          item.types = json[:types]

          item
        end
      end
    end
  end
end
