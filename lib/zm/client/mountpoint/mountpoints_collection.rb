# frozen_string_literal: true

module Zm
  module Client
    # collection of mountpoints
    class MountPointsCollection < Base::AccountObjectsCollection
      attr_reader :root

      attr_accessor :view, :tr, :visible, :needGranteeName, :depth

      def initialize(parent)
        @child_class = MountPoint
        @builder_class = MountPointsBuilder
        super(parent)
        @root = nil
        reset_query_params
      end

      def where(view: nil, tr: nil)
        @view = view
        @tr = tr
        @all = nil
        self
      end

      def clear
        @all = nil
        @root = nil
        reset_query_params
      end

      private

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

      def jsns_builder
        @jsns_builder ||= FoldersJsnsBuilder.new(self)
      end
    end
  end
end
