# frozen_string_literal: true

module Zm
  module Client
    # class for Mta Queue jsns builder
    class MtaQueueJsnsBuilder
      def initialize(item)
        @item = item
      end

      def to_jsns(op, ids)
        soap_request = SoapRequest::SoapElement.admin(Zm::SoapRequest::SoapAdminConstants::MAIL_QUEUE_ACTION_REQUEST)
        node_server = SoapRequest::SoapElement.create('server').add_attribute(SoapRequest::SoapConstants::NAME, @item.server.name)
        soap_request.add_node(node_server)
        node_queue = SoapRequest::SoapElement.create('queue')
        node_server.add_node(node_queue)
        node_action = SoapRequest::SoapElement.create('action').add_attributes({ op: op, by: :id }).add_content(ids.join(','))
        node_queue.add_node(node_action)

        soap_request
      end

      def to_list
        query = {
          offset: @item.offset,
          limit: @item.limit
        }
        query[:field] = @item.fields.map { |k, v| { name: k, match: { value: v } } } unless @item.fields.empty?
        query.reject! { |_, v| v.nil? || v.empty? }

        soap_request = SoapRequest::SoapElement.admin(Zm::SoapRequest::SoapAdminConstants::GET_MAIL_QUEUE_REQUEST)
        node_server = SoapRequest::SoapElement.create('server').add_attribute(SoapRequest::SoapConstants::NAME, @item.server.name)
        soap_request.add_node(node_server)
        node_queue = SoapRequest::SoapElement.create('queue').add_attributes({ name: @item.mta_queue.name, scan: 1, query: query })
        node_server.add_node(node_queue)

        soap_request
      end
    end
  end
end
