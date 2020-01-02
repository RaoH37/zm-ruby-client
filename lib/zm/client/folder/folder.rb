# frozen_string_literal: true

module Zm
  module Client
    # class for account folder
    class Folder < Base::AccountObject
      attr_accessor :type, :id, :uuid, :name, :absFolderPath, :l, :luuid, :f,
                    :view, :rev, :ms, :webOfflineSyncDays, :activesyncdisabled,
                    :n, :s, :i4ms, :i4next, :folder, :zid, :rid, :ruuid,
                    :owner, :reminder, :acl, :itemCount

      alias nb_messages n
      alias nb_items n
      alias parent_id l
      alias size s

      def initialize(parent, json = nil, key = :folder)
        @parent = parent
        @type = key
        init_from_json(json) if json.is_a?(Hash)
        yield(self) if block_given?
      end

      def concat
        [
          @type, @id, @uuid, @name, @absFolderPath, @l, @luuid, @f, @view, @rev,
          @ms, @webOfflineSyncDays, @activesyncdisabled, @n, @s, @i4ms, @i4next,
          @folder, @zid, @rid, @ruuid, @owner, @reminder, @acl
        ]
      end

      def create!
        rep = @parent.sacc.create_folder(@parent.token, @l, @name, @view)
        init_from_json(rep[:Body][:CreateFolderResponse][:folder].first)
      end

      def reload!
        rep = @parent.sacc.get_folder(@parent.token, @id)
        init_from_json(rep[:Body][:GetFolderResponse][:folder].first)
      end

      def empty?
        @n.zero?
      end

      def empty!
        @parent.sacc.folder_action(
          @parent.token,
          :empty,
          @id,
          recursive: false
        )
      end
      alias clear empty!

      def delete!
        @parent.sacc.folder_action(@parent.token, :delete, @id)
      end

      def grant!(parent, right)
        @parent.sacc.folder_action(
          @parent.token,
          'grant',
          @id,
          grant: {
            zid: parent.zimbra_id, perm: right
          }
        )
      end

      def remove_grant!(zid)
        @parent.sacc.folder_action(
          @parent.token,
          '!grant',
          @id,
          zid: zid
        )
      end

      def import!(file_path)
        # todo
      end

      def init_from_json(json)
        @id                 = json[:id].to_i
        @uuid               = json[:uuid]
        @name               = json[:name]
        @absFolderPath      = json[:absFolderPath]
        @l                  = json[:l]
        @luuid              = json[:luuid]
        @f                  = json[:f]
        @view               = json[:view]&.to_sym
        @rev                = json[:rev]
        @ms                 = json[:ms]
        @webOfflineSyncDays = json[:webOfflineSyncDays]
        @activesyncdisabled = json[:activesyncdisabled]
        @n                  = json[:n].to_i
        @s                  = json[:s]
        @i4ms               = json[:i4ms]
        @i4next             = json[:i4next]
        @zid                = json[:zid]
        @rid                = json[:rid]
        @ruuid              = json[:ruuid]
        @owner              = json[:owner]
        @reminder           = json[:reminder]
        @acl                = json[:acl]
      end
    end
  end
end
