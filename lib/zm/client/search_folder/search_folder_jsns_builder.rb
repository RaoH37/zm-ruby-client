# frozen_string_literal: true

module Zm
  module Client
    # class for account search folder jsns builder
    class SearchFolderJsnsBuilder
      def initialize(search_folder)
        @item = search_folder
      end

      def to_jsns
        search = {
          name: @item.name,
          query: @item.query,
          types: @item.types,
          l: @item.l,
          color: @item.color,
          sortBy: @item.sortBy
        }.delete_if { |_, v| v.nil? }

        { search: search }
      end

      alias to_create to_jsns

      def to_modify
        search = {
          id: @item.id,
          query: @item.query,
          types: @item.types
        }.reject { |_, v| v.nil? }

        { search: search }
      end

      def to_update
        action = {
          op: :update,
          id: @item.id,
          name: @item.name,
          color: @item.color,
          rgb: @item.rgb
        }.reject { |_, v| v.nil? }

        { action: action }
      end

      def to_rename(new_name)
        action = {
          op: :rename,
          id: @item.id,
          name: new_name
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

      def to_delete
        { action: { op: :delete, id: @item.id } }
      end
    end
  end
end
