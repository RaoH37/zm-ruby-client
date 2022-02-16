# frozen_string_literal: true

module Zm
  module Client
    # class factory [mountpoints]
    class MountPointsBuilder < Base::ObjectsBuilder
      def initialize(account, json)
        @account = account
        @json = json
        @key_link = :link
        @key_folder = :folder
        @list = []
      end

      def make
        root = @json[:Body][:GetFolderResponse][@key_folder]

        construct_tree(root)

        @list
      end

      def construct_tree(json_folders)
        json_folders.each do |json_folder|
          if json_folder[@key_link].is_a?(Array)
            @list += json_folder[@key_link].map do |json_link|
              MountpointJsnsInitializer.create(@account, json_link)
            end
          end

          next if json_folder[@key_folder].nil? || json_folder[@key_folder].empty?

          construct_tree(json_folder[@key_folder])
        end
      end
    end
  end
end
