# frozen_string_literal: true

module Zm
  module Client
    # class for account document
    class Document < Base::AccountObject
      INSTANCE_VARIABLE_KEYS = %i[id uuid name s d l luuid ms mdver md rev f tn t meta ct descEnabled ver leb cr cd acl
                                  loid sf tn].freeze

      attr_accessor(*INSTANCE_VARIABLE_KEYS)
      attr_writer :folder
      attr_reader :json

      alias parent_id l

      def initialize(parent, json = nil)
        @parent = parent
        init_from_json(json) if json.is_a?(Hash)
        yield(self) if block_given?
      end

      def all_instance_variable_keys
        INSTANCE_VARIABLE_KEYS
      end

      def folder
        @folder ||= @parent.folders.all.find { |folder| folder.id == l }
      end

      def tag!(tag_name)
        @parent.sacc.item_action(@parent.token, :tag, @id, tn: tag_name)
      end

      def move!(folder_id)
        @parent.sacc.item_action(@parent.token, 'move', @id, l: folder_id)
        @l = folder_id
      end

      def delete!
        @parent.sacc.item_action(@parent.token, :delete, @id)
      end

      def download(dest_file_path)
        uploader = Upload.new(@parent, RestAccountConnector.new)
        uploader.download_file(folder.absFolderPath, nil, nil, [id], dest_file_path)
      end
    end
  end
end
