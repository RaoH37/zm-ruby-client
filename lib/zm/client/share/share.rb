# frozen_string_literal: true

module Zm
  module Client
    # class for account share
    class Share < Base::AccountObject
       INSTANCE_VARIABLE_KEYS = %i[
         ownerId ownerEmail ownerName folderId folderUuid folderPath
         view rights granteeType granteeId granteeName mid
      ].freeze

      attr_accessor(*INSTANCE_VARIABLE_KEYS)

      def initialize(parent, json = nil)
        @parent = parent
        init_from_json(json) if json.is_a?(Hash)
        yield(self) if block_given?
      end

      def all_instance_variable_keys
        INSTANCE_VARIABLE_KEYS
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
    end
  end
end
