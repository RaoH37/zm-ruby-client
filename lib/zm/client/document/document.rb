# frozen_string_literal: true

module Zm
  module Client
    # class for account document
    class Document < Base::AccountObject

      INSTANCE_VARIABLE_KEYS = %i[id uuid name s d l luuid ms mdver md rev f tn t meta ct descEnabled ver leb cr cd acl loid sf tn]

      attr_accessor *INSTANCE_VARIABLE_KEYS
      attr_writer :folder
      attr_reader :json

      alias parent_id l

      def initialize(parent, json = nil)
        @parent = parent
        init_from_json(json) if json.is_a?(Hash)
        yield(self) if block_given?
      end

      def concat
        INSTANCE_VARIABLE_KEYS.map { |key| instance_variable_get(arrow_name(key)) }
      end

      def folder
        @folder ||= @parent.folders.all.find { |folder| folder.id == l }
      end

      def download(dest_file_path)
        uploader = Upload.new(@parent, RestAccountConnector.new)
        uploader.download_file(folder.absFolderPath, nil, nil, [id], dest_file_path)
      end

      def init_from_json(json)
        INSTANCE_VARIABLE_KEYS.each do |key|
          var_name = "@#{key}"
          instance_variable_set(var_name, json[key])
        end
      end
    end
  end
end
