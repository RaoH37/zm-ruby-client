# frozen_string_literal: true

module Zm
  module Client
    # collection of search folders
    class SearchFoldersCollection < Base::AccountObjectsCollection
      def initialize(parent)
        @child_class = SearchFolder
        @builder_class = SearchFoldersBuilder
        super(parent)
      end

      private

      def make_query
        @parent.sacc.jsns_request(:GetSearchFolderRequest, @parent.token, nil)
      end
    end
  end
end
