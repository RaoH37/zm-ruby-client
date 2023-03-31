# frozen_string_literal: true

module Zm
  module Client
    # class for account tag jsns builder
    class BaseAccountJsnsBuilder
      def initialize(item)
        @item = item
      end

      def to_tag(tag_name = nil)
        tag_name ||= @item.tn
        { action: { op: :tag, id: @item.id, tn: tag_name } }
      end

      def to_move(new_folder_id = nil)
        new_folder_id ||= @item.l
        { action: { op: :move, id: @item.id, l: new_folder_id } }
      end

      def to_patch(hash)
        action = {
         op: :update,
         id: @item.id
        }.merge(hash)

        action.reject! { |_, v| v.nil? }

        { action: action }
      end

      def to_delete
        action = {
         op: :delete,
         id: @item.id
        }

        { action: action }
      end

      def to_rename(new_name = nil)
        new_name ||= @item.name

        action = {
         op: :rename,
         id: @item.id,
         name: new_name
        }

        { action: action }
      end
    end
  end
end
