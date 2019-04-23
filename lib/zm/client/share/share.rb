module Zm
  module Client
    class Share < Base::Object

      attr_accessor :ownerId, :ownerEmail, :ownerName, :folderId, :folderUuid, :folderPath, :view, :rights, :granteeType, :granteeId, :granteeName, :mid

      def initialize(account, json)
        @account     = account
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

      def to_s
        [@ownerId, @ownerEmail, @ownerName, @folderId, @folderUuid, @folderPath, @view, @rights, @granteeType, @granteeId, @granteeName, @mid].join(" :: ")
      end

      def create!
        options = { grant: { gt: granteeType, d: granteeName, perm: rights } }
        @account.soap_account_connector.folder_action(@account.token, :grant, folderId, options)
      end

      def create_mountpoint!(name = nil)
        name ||= default_mountpoint_name
        @account.sacc.create_mountpoint(
          @account.token,
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
    end
  end
end
