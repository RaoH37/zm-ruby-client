# frozen_string_literal: true

module Zm
  module Client
    # class for account data source jsns builder
    class DataSourceJsnsBuilder
      def initialize(item)
        @item = item
      end

      def to_patch(hash)
        attrs = {
          id: @item.id
        }.merge(hash)

        attrs.compact!

        soap_request = SoapElement.mail(SoapMailConstants::MODIFY_DATA_SOURCE_REQUEST)
        node_action = SoapElement.create(@item.type).add_attributes(attrs)
        soap_request.add_node(node_action)
        soap_request
      end

      def to_delete
        soap_request = SoapElement.mail(SoapMailConstants::DELETE_DATA_SOURCE_REQUEST)
        node_action = SoapElement.create(@item.type).add_attributes(id: @item.id)
        soap_request.add_node(node_action)
        soap_request
      end
    end
  end
end
