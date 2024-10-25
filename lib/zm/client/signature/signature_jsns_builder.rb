# frozen_string_literal: true

module Zm
  module Client
    # class for account signature jsns builder
    class SignatureJsnsBuilder
      def initialize(signature)
        @signature = signature
      end

      def to_jsns
        soap_request = SoapElement.account(SoapAccountConstants::CREATE_SIGNATURE_REQUEST)
        node_signature = SoapElement.create(SoapConstants::SIGNATURE).add_attributes({ name: @signature.name })
        soap_request.add_node(node_signature)
        node_content = SoapElement.create(SoapConstants::CONTENT)
                                  .add_attribute(SoapConstants::TYPE, @signature.type)
                                  .add_content(@signature.content)
        node_signature.add_node(node_content)
        soap_request
      end

      def to_update
        soap_request = SoapElement.account(SoapAccountConstants::MODIFY_SIGNATURE_REQUEST)
        node_signature = SoapElement.create(SoapConstants::SIGNATURE)
                                    .add_attributes({ name: @signature.name, id: @signature.id })
        soap_request.add_node(node_signature)
        node_content = SoapElement.create(SoapConstants::CONTENT)
                                  .add_attribute(SoapConstants::TYPE, @signature.type)
                                  .add_content(@signature.content)
        node_signature.add_node(node_content)
        soap_request
      end

      def to_rename(new_name)
        attrs = {
          id: @signature.id,
          name: new_name
        }

        soap_request = SoapElement.account(SoapAccountConstants::MODIFY_SIGNATURE_REQUEST)
        node_signature = SoapElement.create(SoapConstants::SIGNATURE).add_attributes(attrs)
        soap_request.add_node(node_signature)
        soap_request
      end

      def to_delete
        soap_request = SoapElement.account(SoapAccountConstants::DELETE_SIGNATURE_REQUEST)
        node_signature = SoapElement.create(SoapConstants::SIGNATURE).add_attribute(SoapConstants::ID, @signature.id)
        soap_request.add_node(node_signature)
        soap_request
      end
    end
  end
end
