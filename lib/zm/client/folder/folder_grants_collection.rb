# frozen_string_literal: true

module Zm
  module Client
    # class for folder retention policies collection
    class FolderGrantsCollection

      attr_reader :parent, :all

      def initialize(parent)
        @parent = parent
        @all = []
      end

      def new(zid, gt, perm, d)
        FolderGrant.new(self, zid, gt, perm, d)
      end

      def create(zid, gt, perm, d)
        fg = new(zid, gt, perm, d)
        add(fg)
      end

      def add(fg)
        @all << fg
      end

      def soap_account_connector
        @parent.soap_account_connector
      end

      alias sacc soap_account_connector
    end
  end
end
