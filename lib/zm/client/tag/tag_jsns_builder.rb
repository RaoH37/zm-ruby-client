# frozen_string_literal: true

module Zm
  module Client
    # class for account tag jsns builder
    class TagJsnsBuilder < BaseAccountJsnsBuilder
      def to_jsns
        attrs = {
          name: @item.name,
          color: @item.color,
          rgb: @item.rgb
        }.delete_if { |_, v| v.nil? }

        soap_request = SoapElement.mail(SoapMailConstants::CREATE_TAG_REQUEST)
        node_tag = SoapElement.create('tag').add_attributes(attrs)
        soap_request.add_node(node_tag)
        soap_request
      end

      alias to_create to_jsns

      def to_update
        attrs = {
          op: :update,
          id: @item.id,
          color: @item.color,
          rgb: @item.rgb
        }.reject { |_, v| v.nil? }

        build(attrs)
      end
    end
  end
end
