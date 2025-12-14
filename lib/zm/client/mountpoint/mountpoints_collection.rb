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
        super
        @root = nil
        reset_query_params
      end

      def where(view: nil, tr: nil)
        @view = view
        @tr = tr
        self
      end

      def clear
        @root = nil
        reset_query_params
      end

      def jsns_builder
        return @jsns_builder if defined? @jsns_builder

        @jsns_builder = FoldersJsnsBuilder.new(self)
      end

      def make_query
        @parent.soap_connector.invoke(build_query)
      end

      def build_query
        jsns_builder.to_jsns
      end

      private

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
