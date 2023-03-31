# frozen_string_literal: true

module Zm
  module Client
    # class for account folder jsns builder
    class FolderJsnsBuilder < BaseAccountJsnsBuilder
      def to_find
        { folder: { l: @item.id } }
      end

      def to_jsns
        folder = {
          f: @item.f,
          name: @item.name,
          l: @item.l,
          color: @item.color,
          rgb: @item.rgb,
          url: @item.url,
          fb: @item.fb,
          view: @item.view
        }.delete_if { |_, v| v.nil? }

        { folder: folder }
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
          fb: @item.fb,
          view: @item.view
        }.delete_if { |_, v| v.nil? }

        if @item.is_immutable?
          action.delete(:name)
          action.delete(:l)
        end

        { action: action }
      end

      def to_patch(options)
        action = {
          op: :update,
          id: @item.id
        }.merge(options)

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

      def to_retentionpolicy
        retentionpolicy = @item.retention_policies.all.map { |rp| retentionpolicy_jsns(rp) }.reduce({}, :merge)

        {
          action: {
            op: :retentionpolicy,
            id: @item.id,
            retentionPolicy: retentionpolicy
          }
        }
      end

      private

      def retentionpolicy_jsns(rp)
        {
          rp.policy => {
            policy: {
              lifetime: rp.lifetime,
              type: rp.type
            }
          }
        }
      end
    end
  end
end
