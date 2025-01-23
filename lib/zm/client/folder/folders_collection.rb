# frozen_string_literal: true

module Zm
  module Client
    # collection of folders
    class FoldersCollection < Base::AccountObjectsCollection
      attr_reader :root

      attr_accessor :view, :tr, :visible, :needGranteeName, :depth

      def initialize(parent)
        @child_class = Folder
        @builder_class = FoldersBuilder
        super(parent)
        @root = nil
        reset_query_params
      end

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
        @builder_class.new(@parent, make_query).ids
      end

      def clear
        @root = nil
        reset_query_params
      end

      def document
        @view = FolderDefault::BRIEFCASE[:type]
        self
      end

      def appointment
        @view = FolderDefault::CALENDAR[:type]
        self
      end

      def contact
        @view = FolderDefault::CONTACTS[:type]
        self
      end

      def message
        @view = FolderDefault::INBOX[:type]
        self
      end

      def task
        @view = FolderDefault::TASKS[:type]
        self
      end

      def jsns_builder
        @jsns_builder ||= FoldersJsnsBuilder.new(self)
      end

      def build_query
        jsns_builder.to_jsns
      end

      private

      def build_response
        fb = @builder_class.new(@parent, make_query)
        @root = fb.make
        folders = fb.flatten
        folders.select! { |folder| folder.view == @view } unless @view.nil?
        folders
      end

      def make_query
        @parent.sacc.invoke(jsns_builder.to_jsns)
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
