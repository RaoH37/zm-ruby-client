# frozen_string_literal: true

module Zm
  module Client
    # class for account share
    class ShareJsnsInitializer
      class << self
        def create(parent, json)
          item = Share.new(parent)
          update(item, json)
        end

        def update(item, json)
          item.ownerId = json[:ownerId]
          item.ownerEmail = json[:ownerEmail]
          item.ownerName = json[:ownerName]
          item.folderId = json[:folderId]
          item.folderUuid = json[:folderUuid]
          item.folderPath = json[:folderPath]
          item.view = json[:view]
          item.rights = json[:rights]
          item.granteeType = json[:granteeType]
          item.granteeId = json[:granteeId]
          item.granteeName = json[:granteeName]
          item.mid = json[:mid]

          item
        end
      end
    end
  end
end
