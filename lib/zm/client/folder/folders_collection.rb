# frozen_string_literal: true

module Zm
  module Client
    # collection of folders
    class FoldersCollection < Base::ObjectsCollection
      METHODS_MISSING_LIST = %i[select each map length].to_set.freeze

      attr_reader :root

      def initialize(parent)
        @parent = parent
        @root = nil
        reset_query_params
      end

      def new
        folder = Folder.new(@parent)
        yield(folder) if block_given?
        folder
      end

      def where(view: nil, tr: nil)
        @view = view
        @tr = tr
        self
      end

      def ids
        fb = FoldersBuilder.new @parent, make_query
        fb.ids
      end

      private

      def build_response
        rep = make_query
        fb = FoldersBuilder.new @parent, rep
        @root = fb.make
        @all = fb.flatten
        @all.select! { |folder| folder.view == @view } unless @view.nil?
        @all
      end

      def make_query
        @parent.sacc.get_all_folders(@parent.token, @view, @tr)
      end

      def reset_query_params
        @view = nil
        @tr = nil
      end
    end
  end
end
