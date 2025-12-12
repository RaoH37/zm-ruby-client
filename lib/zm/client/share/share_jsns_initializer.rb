# frozen_string_literal: true

module Zm
  module Client
    # class for account share
    class ShareJsnsInitializer
      class << self
        def create(parent, json)
          Share.new(parent).tap do |item|
            update(item, json)
          end
        end

        def update(item, json)
          item.ownerId = json.delete(:ownerId)
          item.ownerEmail = json.delete(:ownerEmail)
          item.ownerName = json.delete(:ownerName)
          item.folderId = json.delete(:folderId)
          item.folderUuid = json.delete(:folderUuid)
          item.folderPath = json.delete(:folderPath)
          item.view = json.delete(:view)
          item.rights = json.delete(:rights)
          item.granteeType = json.delete(:granteeType)
          item.granteeId = json.delete(:granteeId)
          item.granteeName = json.delete(:granteeName)
          item.mid = json.delete(:mid)

          item
        end
      end
    end
  end
end
