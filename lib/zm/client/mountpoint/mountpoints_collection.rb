# frozen_string_literal: true

module Zm
  module Client
    # collection of mountpoints
    class MountPointsCollection < Base::ObjectsCollection
      METHODS_MISSING_LIST = %i[select each map length].to_set.freeze

      attr_reader :root

      def initialize(parent)
        @parent = parent
        @root = nil
        reset_query_params
      end

      def new
        mountpoint = MountPoint.new(@parent)
        yield(mountpoint) if block_given?
        mountpoint
      end

      def where(view: nil, tr: nil)
        @view = view
        @tr = tr
        @all = nil
        self
      end

      def all
        @all || all!
      end

      def all!
        build_response
      end

      def clear
        @all = nil
        @root = nil
        reset_query_params
      end

      private

      def build_response
        @all = MountPointsBuilder.new(@parent, make_query).make
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
