# frozen_string_literal: true

module Zm
  module Client
    # class for account folder
    class FolderGrant < Base::AccountObject
      attr_accessor :zid, :gt, :perm, :d

      class << self
        def create_by_json(parent, json)
          fg = self.new(parent)
          fg.init_from_json(json)
          fg
        end
      end

      def concat
        [zid, gt, perm, d]
      end

      def is_account?
        gt == 'usr'
      end

      def is_dom?
        gt == 'dom'
      end

      def is_dl?
        gt == 'grp'
      end

      def is_public?
        gt == 'pub'
      end

      def is_external?
        gt == 'guest'
      end

      def init_from_json(json)
        @zid = json[:zid]
        @gt = json[:gt]
        @perm = json[:perm]
        @d = json[:d]
      end

      def to_h
        {
            zid: @zid,
            gt: @gt,
            perm: @perm,
            d: @d
        }
      end
    end
  end
end
