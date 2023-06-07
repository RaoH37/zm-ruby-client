# frozen_string_literal: true

module Zm
  module Client
    # collection of shares
    class SharesCollection < Base::ObjectsCollection
      def initialize(parent)
        @parent = parent
        reset_query_params
      end

      def where(owner_name: nil)
        @owner_name = owner_name
        self
      end

      private

      def build_response
        share_builder.make
      end

      def share_response
        soap_request = SoapElement.account(SoapAccountConstants::GET_SHARE_INFO_REQUEST).add_attributes({ includeSelf: 0 })

        unless @owner_name.nil?
          node_owner = SoapElement.create('owner').add_attributes({ by: :name}).add_content(@owner_name)
          soap_request.add_node(node_owner)
        end

        @parent.sacc.invoke(soap_request)
      end

      def share_builder
        ShareBuilder.new(@parent, share_response)
      end

      def reset_query_params
        @owner_name = nil
      end
    end
  end
end
