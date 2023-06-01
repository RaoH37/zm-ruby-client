# frozen_string_literal: true

module Zm
  module Client
    # class for cos jsns builder
    class CosJsnsBuilder
      def initialize(item)
        @item = item
      end

      def to_create
        soap_request = SoapElement.admin(SoapAdminConstants::CREATE_COS_REQUEST)
        node_cos = SoapElement.create(SoapConstants::NAME).add_content(@item.name)
        soap_request.add_node(node_cos)

        attrs_only_set_h.each do |key, values|
          values.each do |value|
            node_attr = SoapElement.create(SoapConstants::A).add_attribute(SoapConstants::N, key).add_content(value)
            soap_request.add_node(node_attr)
          end
        end

        soap_request
      end

      def to_update
        soap_request = SoapElement.admin(SoapAdminConstants::MODIFY_COS_REQUEST)
        node_cos = SoapElement.create(SoapConstants::ID).add_content(@item.id)
        soap_request.add_node(node_cos)

        attrs_only_set_h.each do |key, values|
          values.each do |value|
            node_attr = SoapElement.create(SoapConstants::A).add_attribute(SoapConstants::N, key).add_content(value)
            soap_request.add_node(node_attr)
          end
        end

        soap_request
      end

      def to_patch(hash)
        soap_request = SoapElement.admin(SoapAdminConstants::MODIFY_COS_REQUEST)
        node_cos = SoapElement.create(SoapConstants::ID).add_content(@item.id)
        soap_request.add_node(node_cos)

        hash.each do |key, values|
          values = [values] unless values.is_a?(Array)
          values.each do |value|
            node_attr = SoapElement.create(SoapConstants::A).add_attribute(SoapConstants::N, key).add_content(value)
            soap_request.add_node(node_attr)
          end
        end

        soap_request
      end

      def attrs_only_set_h
        selected_attrs = @item.attrs_write.map { |a| Utils.arrow_name_sym(a) }
        attrs_only_set = @item.instance_variables & selected_attrs

        arr = attrs_only_set.map do |name|
          n = name.to_s[1..]
          values = @item.instance_variable_get(name)
          values = [values] unless values.is_a?(Array)
          [n, values]
        end

        Hash[arr]
      end
    end
  end
end
