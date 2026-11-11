# frozen_string_literal: true

module Zm
  module Client
    # collection of folders
    class FoldersCollection < Base::AccountObjectsCollection
      attr_accessor :view, :tr, :visible, :needGranteeName, :depth

      def initialize(parent)
        @child_class = Folder
        @builder_class = FoldersBuilder
        super

        reset_query_params
      end

      # TODO: forcer id en string
      def find(id)
        folder = @child_class.new(@parent) do |f|
          f.id = id
        end
        folder.reload!
        folder
      end

      def root
        find(1)
      end

      def where(view: nil, tr: nil)
        @view = view
        @tr = tr
        self
      end

      def ids
        folder_builder.ids
      end

      def document
        @view = FolderDefault::BRIEFCASE.type
        self
      end

      def appointment
        @view = FolderDefault::CALENDAR.type
        self
      end

      def contact
        @view = FolderDefault::CONTACTS.type
        self
      end

      def message
        @view = FolderDefault::INBOX.type
        self
      end

      def task
        @view = FolderDefault::TASKS.type
        self
      end

      def jsns_builder
        return @jsns_builder if defined? @jsns_builder

        @jsns_builder = FoldersJsnsBuilder.new(self)
      end

      def build_query
        jsns_builder.to_jsns
      end

      def tree
        folder_builder.make
      end

      def clear
        reset_query_params
      end

      private

      def build_response
        view = @view
        folders = folder_builder.flatten(collector: FoldersResponse.new)
        # When folders are filtered by view, unknown folders remain in the list
        folders.select! { |folder| folder.view == view } unless view.nil?
        folders
      end

      def folder_builder
        @builder_class.new(@parent, make_query)
      end

      def make_query
        response = @parent.soap_connector.invoke(jsns_builder.to_jsns)
        reset_query_params
        response
      end

      def reset_query_params
        @view = nil
        @tr = nil
        @visible = nil
        @needGranteeName = nil
        @depth = nil
      end
    end
  end
end
