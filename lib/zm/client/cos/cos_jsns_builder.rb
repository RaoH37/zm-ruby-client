# frozen_string_literal: true

module Zm
  module Client
    # class for cos jsns builder
    class CosJsnsBuilder
      def initialize(item)
        @item = item
      end

      def to_create
        soap_request = SoapRequest::SoapElement.admin(Zm::SoapRequest::SoapAdminConstants::CREATE_COS_REQUEST)
        node_cos = SoapRequest::SoapElement.create(SoapRequest::SoapConstants::NAME).add_content(@item.name)
        soap_request.add_node(node_cos)

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

      def to_update
        soap_request = SoapRequest::SoapElement.admin(Zm::SoapRequest::SoapAdminConstants::MODIFY_COS_REQUEST)
        node_cos = SoapRequest::SoapElement.create(SoapRequest::SoapConstants::ID)
                              .add_content(@item.id)
        soap_request.add_node(node_cos)

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

      def to_patch(hash)
        soap_request = SoapRequest::SoapElement.admin(Zm::SoapRequest::SoapAdminConstants::MODIFY_COS_REQUEST)
        node_cos = SoapRequest::SoapElement.create(SoapRequest::SoapConstants::ID)
                              .add_content(@item.id)
        soap_request.add_node(node_cos)

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

      def to_copy(new_name)
        soap_request = SoapRequest::SoapElement.admin(Zm::SoapRequest::SoapAdminConstants::COPY_COS_REQUEST)
        node_name = SoapRequest::SoapElement.create(SoapRequest::SoapConstants::NAME)
                               .add_content(new_name)

        if @item.id
          node_cos = SoapRequest::SoapElement.create(SoapRequest::SoapConstants::COS)
                                .add_attribute(SoapRequest::SoapConstants::BY, SoapRequest::SoapConstants::ID)
                                .add_content(@item.id)
        elsif @item.name
          node_cos = SoapRequest::SoapElement.create(SoapRequest::SoapConstants::COS)
                                .add_attribute(SoapRequest::SoapConstants::BY, SoapRequest::SoapConstants::NAME)
                                .add_content(@item.name)
        else
          raise Zm::Error::ZmError, 'id or name attributes are required to clone cos'
        end

        soap_request.add_node(node_name)
        soap_request.add_node(node_cos)
        soap_request
      end

      def to_delete
        SoapRequest::SoapElement.admin(Zm::SoapRequest::SoapAdminConstants::DELETE_COS_REQUEST).add_node(
          SoapRequest::SoapElement.create(SoapRequest::SoapConstants::ID).add_content(@item.id)
        )
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

        arr.to_h
      end
    end
  end
end
