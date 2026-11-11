# frozen_string_literal: true

module Zm
  module Client
    # folders returned by FoldersCollection#all
    class FoldersResponse < Array
      include FolderViewFilters

      def immutables
        select(&:immutable?)
      end
    end
  end
end
