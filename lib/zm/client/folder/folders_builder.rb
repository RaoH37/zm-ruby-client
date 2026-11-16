# frozen_string_literal: true

module Zm
  module Client
    # class factory [folders]
    class FoldersBuilder < Base::ObjectsBuilder
      def initialize(parent, json)
        super
        @key = :folder
      end

      def ids
        @ids = []
        root = @json[:GetFolderResponse][@key]
        construct_tree_ids(root.first[@key])
        @ids.map! { |id| MailboxItemID.create(id) }
        @ids
      end

      def make
        root = @json[:GetFolderResponse][@key]

        @root_folder = FolderJsnsInitializer.create(@parent, root.first)
        @root_folder.absFolderPath ||= root_path(@root_folder)

        construct_tree(@root_folder, root.first[@key]) if !root.first[@key].nil? && root.first[@key].any?

        @root_folder
      end

      def flatten(folder: make, collector: [])
        collector.push(folder)
        folder.folders.each do |child|
          flatten(folder: child, collector:)
        end
        collector
      end

      private

      def construct_tree_ids(json_folders)
        json_folders.each do |json_folder|
          @ids << json_folder[:id]
          construct_tree_ids(json_folder[@key]) if !json_folder[@key].nil? && json_folder[@key].any?
        end
      end

      def construct_tree(parent_folder, json_folders)
        json_folders.each do |json_folder|
          folder = FolderJsnsInitializer.create(@parent, json_folder)
          folder.absFolderPath ||= child_path(parent_folder.absFolderPath, folder.name)
          folder.view ||= parent_folder.view
          parent_folder.folders << folder

          construct_tree(folder, json_folder[@key]) if !json_folder[@key].nil? && json_folder[@key].any?
        end
      end

      def root_path(folder)
        FolderDefault::ROOT.path if folder.id.to_i == FolderDefault::ROOT.id
      end

      def child_path(parent_path, name)
        return if parent_path.nil? || name.nil?

        parent_path.end_with?('/') ? "#{parent_path}#{name}" : "#{parent_path}/#{name}"
      end
    end
  end
end
