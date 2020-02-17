# frozen_string_literal: true

module Zm
  module Client
    # class factory [folders]
    class FoldersBuilder < Base::ObjectsBuilder
      def initialize(account, json)
        @account = account
        @json = json
        @key = :folder
        @root_folder = nil
      end

      def make
        root = @json[:Body][:GetFolderResponse][@key]

        @root_folder = Folder.new(@account, root.first)

        if !root.first[@key].nil? && root.first[@key].any?
          construct_tree(@root_folder, root.first[@key])
        end

        @root_folder
      end

      def construct_tree(parent_folder, json_folders)
        json_folders.each do |json_folder|
          folder = Folder.new(@account, json_folder)
          parent_folder.folders << folder

          construct_tree(folder, json_folder[@key]) if !json_folder[@key].nil? && json_folder[@key].any?
        end
      end

      def flatten(folder = @root_folder, collector = [])
        collector.push(folder)
        folder.folders.each do |child|
          flatten(child, collector)
        end
        collector
      end
    end
  end
end
