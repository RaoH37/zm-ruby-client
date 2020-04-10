# frozen_string_literal: true

module Zm
  module Client
    # class for account folder
    class Folder < Base::AccountObject

      INSTANCE_VARIABLE_KEYS = %i[type id uuid name absFolderPath l url luuid f
        view rev ms webOfflineSyncDays activesyncdisabled n s i4ms i4next zid rid
        ruuid owner reminder acl itemCount broken deletable color rgb fb]

      attr_accessor *INSTANCE_VARIABLE_KEYS
      attr_accessor :folders, :grants, :retention_policies

      def concat
        INSTANCE_VARIABLE_KEYS.map { |key| instance_variable_get(arrow_name(key)) }
      end

      alias nb_messages n
      alias nb_items n
      alias parent_id l
      alias size s

      def initialize(parent, json = nil, key = :folder)
        @parent = parent
        @type = key
        @folders = []
        @grants = []
        @retention_policies = []
        init_from_json(json) if json.is_a?(Hash)
        yield(self) if block_given?
        extend(DocumentFolder) if view == 'document'
      end

      def is_immutable?
        @is_immutable ||= Zm::Client::FolderDefault::IDS.include?(@id.to_i)
      end

      def to_query
        "inid:#{id}"
      end

      def to_h
        {
          f: f,
          name: name,
          l: l,
          color: color,
          rgb: rgb,
          url: url,
          fb: fb,
          view: view
        }
      end

      def create!
        options = to_h
        options.delete_if { |_, v| v.nil? }
        rep = @parent.sacc.create_folder(@parent.token, options)
        # rep = @parent.sacc.create_folder(@parent.token, @l, @name, @view, @color)
        init_from_json(rep[:Body][:CreateFolderResponse][:folder].first)
      end

      def modify!
        options = to_h
        options.delete_if { |_, v| v.nil? }

        if is_immutable?
          options.delete(:name)
          options.delete(:l)
        end

        update!(options)
      end

      def update!(options)
        @parent.sacc.folder_action(@parent.token, 'update', @id, options)
      end

      def rename!(new_name)
        @parent.sacc.folder_action(@parent.token, 'rename', @id, name: new_name)
        @name = new_name
      end

      def add_retention_policy!(retention_policies)
        options = retention_policies.is_a?(Hash) ? retention_policies : retention_policies.map(&:to_h).reduce({}, :merge)
        @parent.sacc.folder_action(@parent.token, 'retentionPolicy', @id, retentionPolicy: options)
      end

      def move!(folder_id)
        @parent.sacc.folder_action(@parent.token, 'move', @id, l: folder_id)
        @l = folder_id
      end

      def color!(new_color)
        key = new_color.to_i.zero? ? :rgb : :color
        options = {}
        options[key] = new_color
        @parent.sacc.folder_action(@parent.token, 'color', @id, options)
        instance_variable_set("@#{key}", new_color)
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

      #
      # folder_grant: Zm::Client::FolderGrant
      #
      def grant!(folder_grant)
        @parent.sacc.folder_action(
            @parent.token,
            'grant',
            @id,
            grant: folder_grant.to_h
        )
      end

      # def grant!(parent, right)
      #   @parent.sacc.folder_action(
      #     @parent.token,
      #     'grant',
      #     @id,
      #     grant: {
      #       zid: parent.id,
      #       gt: parent.grantee_type,
      #       perm: right
      #     }
      #   )
      # end

      def remove_grant!(zid)
        @parent.sacc.folder_action(
          @parent.token,
          '!grant',
          @id,
          zid: zid
        )
      end

      def retention_policies_h
        @retention_policies.map(&:to_h).reduce({}, :merge)
      end

      def upload(file_path, fmt = nil, types = nil, resolve = 'replace')
        fmt ||= File.extname(file_path)[1..-1]
        # @parent.uploader.send_file(absFolderPath, fmt, types, resolve, file_path)
        uploader = Upload.new(@parent, RestAccountConnector.new)
        uploader.send_file(absFolderPath, fmt, types, resolve, file_path)
      end

      def import(file_path)
        uploader = Upload.new(@parent, RestAccountConnector.new)
        uploader.send_file(absFolderPath, 'tgz', nil, 'skip', file_path)
      end

      def download(dest_file_path, fmt = 'tgz')
        uploader = Upload.new(@parent, RestAccountConnector.new)
        uploader.download_file(absFolderPath, fmt, [view], nil, dest_file_path)
      end

      def export(dest_file_path)
        h = {
          fmt: 'tgz',
          emptyname: 'Vide',
          charset: 'UTF-8',
          auth: 'qp',
          zauthtoken: @parent.token,
          query: to_query
        }

        url_query = absFolderPath + '?' + h.map { |k, v| [k, v].join('=') }.join('&')

        @parent.uploader.download_file_with_url(url_query, dest_file_path)
      end

      def init_from_json(json)
        INSTANCE_VARIABLE_KEYS.each do |key|
          var_name = "@#{key}"
          instance_variable_set(var_name, json[key])
        end

        if !json[:acl].nil? && json[:acl][:grant].is_a?(Array)
          @grants = json[:acl][:grant].map { |grant| FolderGrant.create_by_json(self, grant) }
        end

        if json[:retentionPolicy].is_a?(Array)
          @retention_policies = json[:retentionPolicy].first.map do |k, v|
            FolderRetentionPolicy.create_by_json(self, k, v.first)
          end
        end
      end
    end
  end
end
