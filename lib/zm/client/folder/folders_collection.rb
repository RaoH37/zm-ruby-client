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

      def where(view: nil, tr: nil)
        @view = view
        @tr = tr
        @all = nil
        self
      end

      def ids
        @builder_class.new(@parent, make_query).ids
      end

      def clear
        @all = nil
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

      private

      def build_response
        fb = @builder_class.new(@parent, make_query)
        @root = fb.make
        @all = fb.flatten
        @all.select! { |folder| folder.view == @view } unless @view.nil?
        @all
      end

      def make_query
        @parent.sacc.get_folder(@parent.token, jsns_builder.to_jsns)
      end

      def reset_query_params
        @view = nil
        @tr = nil
        @visible = nil
        @needGranteeName = nil
        @depth = nil
      end

      def jsns_builder
        @jsns_builder ||= FoldersJsnsBuilder.new(self)
      end
    end
  end
end
