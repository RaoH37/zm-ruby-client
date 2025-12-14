# frozen_string_literal: true

module Zm
  module Client
    # class for account folder
    class MountpointJsnsBuilder < BaseAccountJsnsBuilder
      def to_find
        { link: { l: @item.id } }
      end

      def to_jsns
        link = {
          f: @item.f,
          name: @item.name,
          l: @item.l,
          color: @item.color,
          rgb: @item.rgb,
          url: @item.url,
          view: @item.view,
          zid: @item.zid,
          rid: @item.rid
        }
        link.compact!

        attrs = { link: link }

        SoapElement.mail(SoapMailConstants::CREATE_MOUNTPOINT_REQUEST)
                   .add_attributes(attrs)
      end

      alias to_create to_jsns

      def to_update
        attrs = {
          op: :update,
          id: @item.id,
          f: @item.f,
          name: @item.name,
          l: @item.l,
          color: @item.color,
          rgb: @item.rgb,
          url: @item.url,
          view: @item.view
        }
        attrs.compact!

        if @item.is_immutable?
          attrs.delete(:name)
          attrs.delete(:l)
        end

        build(attrs)
      end
    end
  end
end
