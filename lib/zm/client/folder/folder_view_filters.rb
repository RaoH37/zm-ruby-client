# frozen_string_literal: true

module Zm
  module Client
    # filters by view of an Array of folders or mountpoints
    module FolderViewFilters
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

      def by_view(view)
        select { |item| item.view == view }
      end
    end
  end
end
