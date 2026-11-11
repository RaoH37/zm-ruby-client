# frozen_string_literal: true

module Zm
  module Client
    # folders returned by FoldersCollection#all
    class FoldersResponse < Array
      def messages
        by_view(FolderView::MESSAGE)
      end

      def appointments
        by_view(FolderView::APPOINTMENT)
      end

      def contacts
        by_view(FolderView::CONTACT)
      end

      def tasks
        by_view(FolderView::TASK)
      end

      def documents
        by_view(FolderView::DOCUMENT)
      end

      def immutables
        select(&:immutable?)
      end

      def by_view(view)
        select { |folder| folder.view == view }
      end
    end
  end
end
