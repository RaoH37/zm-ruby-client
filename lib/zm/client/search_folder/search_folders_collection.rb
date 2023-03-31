# frozen_string_literal: true

module Zm
  module Client
    # collection of folders
    class SearchFoldersCollection < Base::ObjectsCollection
      METHODS_MISSING_LIST = %i[select each map length].to_set.freeze

      def initialize(parent)
        @parent = parent
      end

      def new
        folder = SearchFolder.new(@parent)
        yield(folder) if block_given?
        folder
      end

      private

      def build_response
        rep = @parent.sacc.get_all_search_folders(@parent.token)
        fb = SearchFoldersBuilder.new @parent, rep
        fb.make
      end
    end
  end
end
