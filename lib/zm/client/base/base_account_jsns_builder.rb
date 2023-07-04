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

        attrs = {
         op: :tag,
         id: @item.id,
         tn: tag_name
        }

        build(attrs)
      end

      def to_move(new_folder_id = nil)
        new_folder_id ||= @item.l

        attrs = {
         op: :move,
         id: @item.id,
         l: new_folder_id
        }

        build(attrs)
      end

      def to_patch(hash)
        attrs = {
          op: :update,
          id: @item.id
        }.merge(hash)

        attrs.reject! { |_, v| v.nil? }

        build(attrs)
      end

      def to_delete
        attrs = {
          op: :delete,
          id: @item.id
        }

        build(attrs)
      end

      def to_rename(new_name = nil)
        new_name ||= @item.name

        attrs = {
          op: :rename,
          id: @item.id,
          name: new_name
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

      def to_empty
        attrs = {
          op: :empty,
          id: @item.id,
          recursive: false
        }

        build(attrs)
      end

      def build(attrs)
        soap_request = SoapElement.mail(SoapMailConstants::ITEM_ACTION_REQUEST)
        node_action = SoapElement.create(SoapConstants::ACTION).add_attributes(attrs)
        soap_request.add_node(node_action)
        soap_request
      end
    end
  end
end
