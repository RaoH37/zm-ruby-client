# frozen_string_literal: true

module Zm
  module Client
    # class for distribution list jsns builder
    class DistributionListJsnsBuilder
      include Base::ZimbraAttrsJsns

      def initialize(item)
        @item = item
      end

      def to_create
        soap_request = SoapRequest::SoapElement.admin(Zm::SoapRequest::SoapAdminConstants::CREATE_DISTRIBUTION_LIST_REQUEST)
                                               .add_attribute(SoapRequest::SoapConstants::NAME, @item.name)

        add_attr_nodes(soap_request, attrs_only_set_h)
      end

      def to_update(force: false)
        soap_request = SoapRequest::SoapElement.admin(Zm::SoapRequest::SoapAdminConstants::MODIFY_DISTRIBUTION_LIST_REQUEST)
                                               .add_attribute(SoapRequest::SoapConstants::ID, @item.id)

        add_attr_nodes(soap_request, attrs_to_update_h(force))
      end

      def to_patch(hash)
        soap_request = SoapRequest::SoapElement.admin(Zm::SoapRequest::SoapAdminConstants::MODIFY_DISTRIBUTION_LIST_REQUEST)
                                               .add_attribute(SoapRequest::SoapConstants::ID, @item.id)

        add_attr_nodes(soap_request, hash)
      end

      def to_delete
        SoapRequest::SoapElement.admin(Zm::SoapRequest::SoapAdminConstants::DELETE_DISTRIBUTION_LIST_REQUEST)
                                .add_attribute(SoapRequest::SoapConstants::ID, @item.id)
      end

      def to_rename(new_name)
        SoapRequest::SoapElement.admin(Zm::SoapRequest::SoapAdminConstants::RENAME_DISTRIBUTION_LIST_REQUEST)
                                .add_attributes({ id: @item.id, newName: new_name })
      end

      private

      def add_attr_nodes(soap_request, hash)
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
    end
  end
end
