# frozen_string_literal: true

module Zm
  module Client
    # class for account tag jsns builder
    class BaseAccountJsnsBuilder
      def initialize(item)
        @item = item
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

      def to_rename
        action = {
         op: :rename,
         id: @item.id,
         name: @item.name
        }

        { action: action }
      end
    end
  end
end
