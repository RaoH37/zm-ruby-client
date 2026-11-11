# frozen_string_literal: true

module Zm
  module Client
    # class for folder retention policies collection
    class FolderGrantsCollection
      include Zm::Utils::MissingMethodStaticCollection

      attr_reader :parent

      def initialize(parent)
        @parent = parent
        @all = []
      end

      def new_from_object(item, perm)
        case item
        when Account
          zid = item.id
          gt = FolderGrant::GT_USER
        when Resource
          zid = item.id
          gt = FolderGrant::GT_USER
        when DistributionList
          zid = item.id
          gt = FolderGrant::GT_GROUP
        when Domain
          zid = item.id
          gt = FolderGrant::GT_DOMAIN
        else
          zid = nil
          gt = nil
        end

        new(zid, gt, perm, nil)
      end

      def new(zid, gt, perm, d)
        FolderGrant.new(self, zid, gt, perm, d)
      end

      def create(zid, gt, perm, d)
        fg = new(zid, gt, perm, d)
        add(fg)
        fg
      end

      def create_from_object(item, perm)
        fg = new_from_object(item, perm)
        add(fg)
        fg
      end

      def add(fg)
        @all << fg
      end

      def accounts
        @all.select(&:is_account?)
      end

      def distribution_lists
        @all.select(&:is_dl?)
      end

      def domains
        @all.select(&:is_dom?)
      end

      def publics
        @all.select(&:is_public?)
      end

      def externals
        @all.select(&:is_external?)
      end

      def keys
        @all.select(&:is_key?)
      end

      def soap_account_connector
        @parent.parent.soap_account_connector
      end

      def soap_connector
        @parent.parent.soap_connector
      end
    end
  end
end
