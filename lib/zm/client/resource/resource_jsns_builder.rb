# frozen_string_literal: true

module Zm
  module Client
    # class for resource jsns builder
    class ResourceJsnsBuilder
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

        soap_request = SoapRequest::SoapElement.admin(Zm::SoapRequest::SoapAdminConstants::CREATE_CALENDAR_RESOURCE_REQUEST)
                                  .add_attributes(req)

        attrs_only_set_h.each do |key, values|
          values.each do |value|
            node_attr = SoapRequest::SoapElement.create(SoapRequest::SoapConstants::A)
                                   .add_attribute(SoapRequest::SoapConstants::N, key)
                                   .add_content(value)
            soap_request.add_node(node_attr)
          end
        end

        soap_request
      end

      def to_update(force: false)
        soap_request = SoapRequest::SoapElement.admin(Zm::SoapRequest::SoapAdminConstants::MODIFY_CALENDAR_RESOURCE_REQUEST)
                                  .add_attribute(SoapRequest::SoapConstants::ID, @item.id)

        attrs_to_update_h(force).each do |key, values|
          values.each do |value|
            node_attr = SoapRequest::SoapElement.create(SoapRequest::SoapConstants::A)
                                   .add_attribute(SoapRequest::SoapConstants::N, key)
                                   .add_content(value)
            soap_request.add_node(node_attr)
          end
        end

        soap_request
      end

      def to_patch(hash)
        soap_request = SoapRequest::SoapElement.admin(Zm::SoapRequest::SoapAdminConstants::MODIFY_CALENDAR_RESOURCE_REQUEST)
                                  .add_attribute(SoapRequest::SoapConstants::ID, @item.id)

        hash.each do |key, values|
          values = [values] unless values.is_a?(Array)
          values.each do |value|
            node_attr = SoapRequest::SoapElement.create(SoapRequest::SoapConstants::A)
                                   .add_attribute(SoapRequest::SoapConstants::N, key)
                                   .add_content(value)
            soap_request.add_node(node_attr)
          end
        end

        soap_request
      end

      def to_delete
        SoapRequest::SoapElement.admin(Zm::SoapRequest::SoapAdminConstants::DELETE_CALENDAR_RESOURCE_REQUEST)
                   .add_attribute(SoapRequest::SoapConstants::ID, @item.id)
      end
    end
  end
end
