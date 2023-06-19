# frozen_string_literal: true

module Zm
  module Client
    # class for account identity jsns builder
    class IdentityJsnsBuilder
      def initialize(item)
        @item = item
      end

      def to_jsns
        soap_request = SoapElement.account(SoapAccountConstants::CREATE_IDENTITY_REQUEST)
        node_identity = SoapElement.create(SoapConstants::IDENTITY).add_attributes({ name: @item.name, _attrs: attrs })
        soap_request.add_node(node_identity)
        soap_request
      end

      def to_update
        soap_request = SoapElement.account(SoapAccountConstants::MODIFY_IDENTITY_REQUEST)
        node_identity = SoapElement.create(SoapConstants::IDENTITY).add_attributes({ id: @item.id, _attrs: attrs })
        soap_request.add_node(node_identity)
        soap_request
      end

      def to_patch(hash)
        soap_request = SoapElement.account(SoapAccountConstants::MODIFY_IDENTITY_REQUEST)
        node_identity = SoapElement.create(SoapConstants::IDENTITY).add_attributes({ id: @item.id, _attrs: hash })
        soap_request.add_node(node_identity)
        soap_request
      end

      def to_delete
        soap_request = SoapElement.account(SoapAccountConstants::DELETE_IDENTITY_REQUEST)
        node_identity = SoapElement.create(SoapConstants::IDENTITY).add_attributes({ id: @item.id })
        soap_request.add_node(node_identity)
        soap_request
      end

      def attrs
        {
          zimbraPrefIdentityName: @item.zimbraPrefIdentityName,
          zimbraPrefFromDisplay: @item.zimbraPrefFromDisplay,
          zimbraPrefFromAddress: @item.zimbraPrefFromAddress,
          zimbraPrefFromAddressType: @item.zimbraPrefFromAddressType,
          zimbraPrefReplyToEnabled: @item.zimbraPrefReplyToEnabled,
          zimbraPrefReplyToDisplay: @item.zimbraPrefReplyToDisplay,
          zimbraPrefReplyToAddress: @item.zimbraPrefReplyToAddress,
          zimbraPrefDefaultSignatureId: @item.zimbraPrefDefaultSignatureId,
          zimbraPrefForwardReplySignatureId: @item.zimbraPrefForwardReplySignatureId,
          zimbraPrefWhenSentToEnabled: @item.zimbraPrefWhenSentToEnabled,
          zimbraPrefWhenInFoldersEnabled: @item.zimbraPrefWhenInFoldersEnabled,
          zimbraPrefWhenSentToAddresses: @item.zimbraPrefWhenSentToAddresses
        }
      end
    end
  end
end
