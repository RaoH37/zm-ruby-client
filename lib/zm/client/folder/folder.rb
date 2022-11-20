# frozen_string_literal: true

module Zm
  module Client
    # class for account folder
    class Folder < Base::FolderObject
      include Zm::Model::AttributeChangeObserver

      INSTANCE_VARIABLE_KEYS = %i[type id uuid name absFolderPath l url luuid f
        view rev ms webOfflineSyncDays activesyncdisabled n s i4ms i4next zid rid
        ruuid owner reminder acl itemCount broken deletable color rgb fb]

      attr_reader :type, :id, :uuid, :absFolderPath, :luuid, :rev, :ms, :webOfflineSyncDays, :activesyncdisabled, :n, :s, :i4ms, :i4next, :zid, :rid, :ruuid, :owner, :reminder, :acl, :itemCount, :broken, :deletable, :fb

      attr_accessor :folders, :grants, :retention_policies

      define_changed_attributes :name, :color, :rgb, :l, :url, :f, :view

      def all_instance_variable_keys
        INSTANCE_VARIABLE_KEYS
      end

      alias nb_messages n
      alias nb_items n
      alias parent_id l
      alias size s

      def initialize(parent)
        super(parent)

        @type = :folder
        @folders = []
        @grants = FolderGrantsCollection.new(self)
        @retention_policies = FolderRetentionPoliciesCollection.new(self)

        yield(self) if block_given?

        extend(DocumentFolder) if view == 'document'
      end

      def is_immutable?
        @is_immutable ||= Zm::Client::FolderDefault::IDS.include?(@id.to_i)
      end

      def to_query
        "inid:#{id}"
      end

      def create!
        rep = @parent.sacc.create_folder(@parent.token, jsns_builder.to_jsns)
        json = rep[:Body][:CreateFolderResponse][:folder].first
        FolderJsnsInitializer.update(self, json)
      end

      def update!(options)
        # todo folder_action utilise maintenant le FolderJsnsBuilder
        @parent.sacc.folder_action(@parent.token, 'update', @id, options)
      end

      def add_retention_policy!(retention_policies)
        options = retention_policies.is_a?(Hash) ? retention_policies : retention_policies.map(&:to_h).reduce({}, :merge)
        @parent.sacc.folder_action(@parent.token, 'retentionPolicy', @id, retentionPolicy: options)
      end

      def reload!
        rep = @parent.sacc.get_folder(@parent.token, jsns_builder.to_find)
        json = rep[:Body][:GetFolderResponse][:folder].first
        FolderJsnsInitializer.update(self, json)
        true
      end

      def empty?
        @n.zero?
      end

      def empty!
        @parent.sacc.folder_action(@parent.token, jsns_builder.to_empty) unless @n.zero?
        @n = 0
      end
      alias clear empty!

      def delete!
        return false if is_immutable?

        super
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
        # uploader.download_file(absFolderPath, fmt, [view], nil, dest_file_path)
        uploader.download_folder(@id, fmt, dest_file_path)
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

      private

      def jsns_builder
        @jsns_builder ||= FolderJsnsBuilder.new(self)
      end
    end
  end
end
