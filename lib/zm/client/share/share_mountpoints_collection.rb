# frozen_string_literal: true

module Zm
  module Client
    # collection of share mountpoints
    class ShareMountPointsCollection
      def initialize(share)
        @share = share
      end

      def new
        MountPoint.new(@share.parent) do |mp|
          mp.l = FolderDefault::ROOT[:id]
          mp.name = default_mountpoint_name
          mp.zid = @share.ownerId
          mp.rid = @share.folderId
          mp.view = @share.view
        end
      end

      def all
        @all || all!
      end

      def all!
        @all = @share.parent.mountpoints.all.select { |mp| mp.zid == @share.ownerId && mp.rid == @share.folderId }
      end

      private

      def default_mountpoint_name
        folder_name = @share.folderPath[1..].split('/').last
        owner_name = (@share.ownerName || @share.ownerEmail).tr('/', '-')
        "#{folder_name} (#{owner_name})"
      end
    end
  end
end
