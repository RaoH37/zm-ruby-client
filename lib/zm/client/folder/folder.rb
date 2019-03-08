module Zm
  module Client
    class Folder < Base::Object
      attr_accessor :type, :id, :uuid, :name, :absFolderPath, :l, :luuid, :f,
                    :view, :rev, :ms, :webOfflineSyncDays, :activesyncdisabled,
                    :n, :s, :i4ms, :i4next, :folder, :zid, :rid, :ruuid,
                    :owner, :reminder, :acl, :itemCount

      alias nb_messages n
      alias parent_id l

      def initialize(account, json = nil, key = :folder)
        @account = account
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

      def to_s
        concat.join(' :: ')
      end

      def create!
        rep = @account.sacc.create_folder(@account.token, @l, @name, @view)
        init_from_json(rep[:Body][:CreateFolderResponse][:folder].first)
      end

      def empty?
        @n.zero?
      end

      def empty!
        @account.sacc.folder_action(
          @account.token,
          :empty,
          @id,
          recursive: false
        )
      end
      alias clear empty!

      def delete!
        @account.sacc.folder_action(@account.token, :delete, @id)
      end

      def grant!(account, right)
        @account.sacc.folder_action(
          @account.token,
          'grant',
          @id,
          grant: {
            zid: account.zimbra_id, perm: right
          }
        )
      end

      def remove_grant!(zid)
        @account.sacc.folder_action(
          @account.token,
          '!grant',
          @id,
          zid: zid
        )
      end

      def import!(file_path)
        # todo
      end

      private

      def init_from_json(json)
        @id                 = json[:id].to_i
        @uuid               = json[:uuid]
        @name               = json[:name]
        @absFolderPath      = json[:absFolderPath]
        @l                  = json[:l]
        @luuid              = json[:luuid]
        @f                  = json[:f]
        @view               = json[:view]
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
