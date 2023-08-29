# frozen_string_literal: true

module Zm
  module Client
    # class for account folder
    class MountpointJsnsBuilder < Base::BaseJsnsBuilder

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
        }.delete_if { |_, v| v.nil? }

        { link: link }
      end

      alias to_create to_jsns

      def to_update
        action = {
          op: :update,
          id: @item.id,
          f: @item.f,
          name: @item.name,
          l: @item.l,
          color: @item.color,
          rgb: @item.rgb,
          url: @item.url,
          view: @item.view
        }.delete_if { |_, v| v.nil? }

        if @item.is_immutable?
          action.delete(:name)
          action.delete(:l)
        end

        { action: action }
      end

      def to_rename
        action = {
          op: :rename,
          id: @item.id,
          name: @item.name
        }

        { action: action }
      end

      def to_move
        action = {
          op: :move,
          id: @item.id,
          l: @item.l
        }

        { action: action }
      end

      def to_color
        action = {
          op: :color,
          id: @item.id
        }

        action[:rgb] = @item.rgb if @item.rgb_changed?
        action[:color] = @item.color if @item.color_changed?

        { action: action }
      end

      def to_empty
        action = {
          op: :empty,
          id: @item.id,
          recursive: false
        }

        { action: action }
      end

      def to_delete
        { action: { op: :delete, id: @item.id } }
      end
    end
  end
end
