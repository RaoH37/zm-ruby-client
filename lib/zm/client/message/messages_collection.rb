# frozen_string_literal: true

module Zm
  module Client
    # Collection Messages
    class MessagesCollection < Base::AccountSearchObjectsCollection
      def initialize(parent)
        super(parent)
        @child_class = Message
        @builder_class = MessagesBuilder
        @type = SoapConstants::MESSAGE
        @sort_by = SoapConstants::DATE_DESC
      end

      def find_each(offset: 0, limit: 500, &block)
        @more = true
        @offset = offset
        @limit = limit

        while @more
          build_response.each { |item| block.call(item) }
          @offset += @limit
        end
      end

      def delete_all(ids)
        attrs = {
          op: :delete,
          id: ids.join(',')
        }

        attrs.delete_if { |_, v| v.nil? }

        soap_request = SoapElement.mail(SoapMailConstants::MSG_ACTION_REQUEST)
        node_action = SoapElement.create(SoapConstants::ACTION).add_attributes(attrs)
        soap_request.add_node(node_action)
        @parent.sacc.invoke(soap_request)
      end

      private

      def build_options
        options = super
        options[:recip] = @recip
        options
      end

      def reset_query_params
        super
        @recip = 2
      end
    end
  end
end
