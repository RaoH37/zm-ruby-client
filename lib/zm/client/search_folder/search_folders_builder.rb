# frozen_string_literal: true

module Zm
  module Client
    # class factory [folders]
    class SearchFoldersBuilder < Base::ObjectsBuilder
      def initialize(account, json)
        @account = account
        @json = json
      end

      def make
        root = @json[:Body][:GetSearchFolderResponse][:search]
        return [] if root.nil?

        root = [root] unless root.is_a?(Array)

        root.map do |s|
          f = SearchFolder.new(@parent)
          f.init_from_json(s)
          f
        end
      end
    end
  end
end
