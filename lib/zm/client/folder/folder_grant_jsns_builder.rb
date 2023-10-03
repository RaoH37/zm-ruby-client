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

        attrs = {
          action: {
            op: :grant,
            id: @item.folder_id,
            grant: grant
          }
        }

        SoapElement.mail(SoapMailConstants::FOLDER_ACTION_REQUEST).add_attributes(attrs)
      end

      alias to_create to_jsns

      def to_delete
        attrs = {
          action: {
            op: '!grant',
            id: @item.folder_id,
            zid: delete_zid,
            gt: @item.gt,
            perm: @item.perm,
            d: @item.d
          }
        }

        SoapElement.mail(SoapMailConstants::FOLDER_ACTION_REQUEST).add_attributes(attrs)
      end

      def delete_zid
        return @item.zid unless @item.zid.nil?

        return '99999999-9999-9999-9999-999999999999' if @item.gt == 'pub'

        '00000000-0000-0000-0000-000000000000'
      end
    end
  end
end
