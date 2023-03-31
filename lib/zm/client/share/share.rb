# frozen_string_literal: true

module Zm
  module Client
    # class for account share
    class Share < Base::AccountObject
      attr_accessor :ownerId, :ownerEmail, :ownerName, :folderId, :folderUuid, :folderPath, :view, :rights,
                    :granteeType, :granteeId, :granteeName, :mid

      def mountpoints
        @mountpoints ||= ShareMountPointsCollection.new(self)
      end
    end
  end
end
