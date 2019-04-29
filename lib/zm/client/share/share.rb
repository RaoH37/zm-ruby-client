module Zm
  module Client
    class Share < Base::AccountObject

      attr_accessor :ownerId, :ownerEmail, :ownerName, :folderId, :folderUuid,
                    :folderPath, :view, :rights, :granteeType, :granteeId,
                    :granteeName, :mid

      def initialize(parent, json = nil)
        @parent = parent
        init_from_json(json) if json.is_a?(Hash)
        yield(self) if block_given?
      end

      def concat
        [
          @ownerId, @ownerEmail, @ownerName, @folderId, @folderUuid, @folderPath,
          @view, @rights, @granteeType, @granteeId, @granteeName, @mid
        ]
      end

      def create!
        options = { grant: { gt: granteeType, d: granteeName, perm: rights } }
        @parent.sacc.folder_action(
          @parent.token,
          :grant,
          folderId,
          options
        )
      end

      def create_mountpoint!(name = nil)
        name ||= default_mountpoint_name
        @parent.sacc.create_mountpoint(
          @parent.token,
          FolderDefault::ROOT[:id],
          name,
          @view,
          @ownerId,
          @folderId
        )
      end

      def default_mountpoint_name
        folder_name = @folderPath[1..-1].split('/').last
        owner_name = (@ownerName || @ownerEmail).tr('/', '-')
        "#{folder_name} (#{owner_name})"
      end

      def init_from_json(json)
        @ownerId     = json[:ownerId]
        @ownerEmail  = json[:ownerEmail]
        @ownerName   = json[:ownerName]
        @folderId    = json[:folderId]
        @folderUuid  = json[:folderUuid]
        @folderPath  = json[:folderPath]
        @view        = json[:view]
        @rights      = json[:rights]
        @granteeType = json[:granteeType]
        @granteeId   = json[:granteeId]
        @granteeName = json[:granteeName]
        @mid         = json[:mid]
      end
    end
  end
end
