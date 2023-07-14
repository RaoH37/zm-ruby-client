# frozen_string_literal: true

module Zm
  module Client
    # class for account search folder jsns builder
    class SearchFolderJsnsBuilder
      def initialize(search_folder)
        @item = search_folder
      end

      def to_jsns
        attrs = {
          name: @item.name,
          query: @item.query,
          types: @item.types,
          l: @item.l,
          color: @item.color,
          sortBy: @item.sortBy
        }.delete_if { |_, v| v.nil? }

        soap_request = SoapElement.mail(SoapMailConstants::CREATE_SEARCH_FOLDER_REQUEST)
        node_search = SoapElement.create(SoapConstants::SEARCH).add_attributes(attrs)
        soap_request.add_node(node_search)
        soap_request
      end

      alias to_create to_jsns

      def to_modify
        attrs = {
          id: @item.id,
          query: @item.query,
          types: @item.types
        }.reject { |_, v| v.nil? }

        soap_request = SoapElement.mail(SoapMailConstants::MODIFY_SEARCH_FOLDER_REQUEST)
        node_search = SoapElement.create(SoapConstants::SEARCH).add_attributes(attrs)
        soap_request.add_node(node_search)
        soap_request
      end

      def to_update
        attrs = {
          op: :update,
          id: @item.id,
          name: @item.name,
          color: @item.color,
          rgb: @item.rgb
        }.reject { |_, v| v.nil? }

        build(attrs)
      end

      def to_rename(new_name)
        attrs = {
          op: :rename,
          id: @item.id,
          name: new_name
        }

        build(attrs)
      end

      def to_move
        attrs = {
          op: :move,
          id: @item.id,
          l: @item.l
        }

        build(attrs)
      end

      def to_color
        attrs = {
          op: :color,
          id: @item.id
        }

        attrs[:rgb] = @item.rgb if @item.rgb_changed?
        attrs[:color] = @item.color if @item.color_changed?

        build(attrs)
      end

      def to_delete
        attrs = {
          op: :delete,
          id: @item.id
        }

        build(attrs)
      end

      def build(attrs)
        soap_request = SoapElement.mail(SoapMailConstants::FOLDER_ACTION_REQUEST)
        node_action = SoapElement.create(SoapConstants::ACTION).add_attributes(attrs)
        soap_request.add_node(node_action)
        soap_request
      end
    end
  end
end
