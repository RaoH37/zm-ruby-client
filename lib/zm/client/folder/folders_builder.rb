module Zm
  module Client
    class FoldersBuilder < Base::ObjectsBuilder
      def initialize(account, json)
        @account = account
        @json = json
      end

      def make
        root = @json[:Body][:GetFolderResponse][:folder]
        folders = FolderType::ALL.map do |key|
          flatten(root, key).map do |f|
            Folder.new(@account, f, key)
          end
        end
        folders.flatten!

        tmp = root.first.clone
        FolderType::ALL.each { |key| tmp.delete(key) }
        folders.unshift Folder.new(@account, tmp, FolderType::FOLDER)

        folders
      end

      def flatten(json, key, collecter = [])
        return collecter unless json.is_a?(Array)

        json.each do |folder|
          tmp = folder.clone
          tmp.delete(key)
          collecter << tmp if tmp[:name] != FolderDefault::ROOT[:name]
          collecter << folder[key] if folder[key].is_a?(Hash)
          flatten(folder[key], key, collecter) if folder[key].is_a?(Array)
        end
        collecter
      end
    end
  end
end
