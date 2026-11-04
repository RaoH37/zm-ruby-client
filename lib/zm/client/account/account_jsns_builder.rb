# frozen_string_literal: true

module Zm
  module Client
    # class for account jsns builder
    class AccountJsnsBuilder
      include Base::ZimbraAttrsJsns

      def initialize(item)
        @item = item
      end

      def to_create
        req = {
          name: @item.name,
          password: @item.password
        }
        req.compact!

        soap_request = SoapRequest::SoapElement.admin(Zm::SoapRequest::SoapAdminConstants::CREATE_ACCOUNT_REQUEST)
                                  .add_attributes(req)

        add_soap_request_nodes(soap_request)

        soap_request
      end

      def add_soap_request_nodes(soap_request, attrs = attrs_only_set_h)
        attrs.each do |key, values|
          values.each do |value|
            add_soap_request_node(soap_request, key, value)
          end
        end
      end

      def add_soap_request_node(soap_request, key, value)
        node_attr = SoapRequest::SoapElement.create(SoapRequest::SoapConstants::A)
                               .add_attribute(SoapRequest::SoapConstants::N, key)
                               .add_content(value)
        soap_request.add_node(node_attr)
      end

      def to_update(force: false)
        soap_request = SoapRequest::SoapElement.admin(Zm::SoapRequest::SoapAdminConstants::MODIFY_ACCOUNT_REQUEST)
                                  .add_attribute(SoapRequest::SoapConstants::ID, @item.id)

        add_soap_request_nodes(soap_request, attrs_to_update_h(force))

        soap_request
      end

      def to_patch(hash)
        soap_request = SoapRequest::SoapElement.admin(Zm::SoapRequest::SoapAdminConstants::MODIFY_ACCOUNT_REQUEST)
                                  .add_attribute(SoapRequest::SoapConstants::ID, @item.id)

        hash.each do |key, values|
          values = [values] unless values.is_a?(Array)
          values.each do |value|
            add_soap_request_node(soap_request, key, value)
          end
        end

        soap_request
      end

      def to_delete
        SoapRequest::SoapElement.admin(Zm::SoapRequest::SoapAdminConstants::DELETE_ACCOUNT_REQUEST)
                   .add_attribute(SoapRequest::SoapConstants::ID, @item.id)
      end

      def to_rename(new_name)
        SoapRequest::SoapElement.admin(Zm::SoapRequest::SoapAdminConstants::RENAME_ACCOUNT_REQUEST)
                   .add_attributes({ id: @item.id, newName: new_name })
      end
    end
  end
end
