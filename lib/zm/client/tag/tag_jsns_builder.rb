# frozen_string_literal: true

module Zm
  module Client
    # class for account tag jsns builder
    class TagJsnsBuilder < BaseAccountJsnsBuilder
      def to_jsns
        tag = {
          name: @item.name,
          color: @item.color,
          rgb: @item.rgb
        }.delete_if { |_, v| v.nil? }

        { tag: tag }
      end

      alias to_create to_jsns

      def to_update
        action = {
          op: :update,
          id: @item.id,
          color: @item.color,
          rgb: @item.rgb
        }.reject { |_, v| v.nil? }

        { action: action }
      end
    end
  end
end
