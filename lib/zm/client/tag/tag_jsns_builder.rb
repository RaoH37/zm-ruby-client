# frozen_string_literal: true

module Zm
  module Client
    # class for account tag jsns builder
    class TagJsnsBuilder

      def initialize(tag)
        @tag = tag
      end

      def to_jsns
        tag = {
          name: @tag.name,
          color: @tag.color,
          rgb: @tag.rgb
        }.delete_if { |_, v| v.nil? }

        { tag: tag }
      end

      alias to_create to_jsns

      def to_update
        action = {
          op: :update,
          id: @tag.id,
          color: @tag.color,
          rgb: @tag.rgb
        }.reject { |_, v| v.nil? }

        { action: action }
      end

      def to_patch(hash)
        action = {
         op: :update,
         id: @tag.id
        }.merge(hash)

        action.reject! { |_, v| v.nil? }

        { action: action }
      end

      def to_delete
        action = {
          op: :delete,
          id: @tag.id
        }

        { action: action }
      end

      def to_rename
        action = {
          op: :rename,
          id: @tag.id,
          name: @tag.name
        }

        { action: action }
      end
    end
  end
end
