# frozen_string_literal: true

module Zm
  module Client
    # class for account folder grant jsns builder
    class FolderGrantJsnsBuilder < Base::BaseJsnsBuilder

      def to_jsns
        grant = {
          zid: @item.zid,
          gt: @item.gt,
          perm: @item.perm,
          d: @item.d,
          expiry: @item.expiry,
          key: @item.key
        }.delete_if { |_, v| v.nil? }

        {
          action: {
            op: :grant,
            id: @item.folder_id,
            grant: grant
          }
        }
      end

      alias to_create to_jsns

      def to_delete
        {
          action: {
            op: '!grant',
            id: @item.folder_id,
            zid: @item.zid,
            gt: @item.gt,
            perm: @item.perm,
            d: @item.d
          }
        }
      end
    end
  end
end
