# frozen_string_literal: true

module Zm
  module Client
    # class for account share
    class Share < Base::Object
      extend Relationship
      attr_accessor :ownerId, :ownerEmail, :ownerName, :folderId, :folderUuid, :folderPath,
                    :view, :rights, :granteeType, :granteeId, :granteeName, :mid

      has_many :mountpoints, klass: :'Zm::Client::ShareMountPointsCollection'
    end
  end
end
