# frozen_string_literal: true

module Zm
  module Client
    # class for account jsns builder
    class AccountJsnsBuilder
      def initialize(item)
        @item = item
      end

      def to_create
        req = { name: @item.name, password: @item.password }
        req.reject! { |_, v| v.nil? }

        soap_request = SoapElement.admin(SoapAdminConstants::CREATE_ACCOUNT_REQUEST)
                                  .add_attributes(req)

        attrs_only_set_h(@item.class.create_keys).each do |key, values|
          values.each do |value|
            soap_request.add_node(node_attr(key, value))
          end
        end

        soap_request
      end

      def to_update
        soap_request = SoapElement.admin(SoapAdminConstants::MODIFY_ACCOUNT_REQUEST)
                                  .add_attribute(SoapConstants::ID, @item.id)

        attrs_only_set_h(@item.class.update_keys).each do |key, values|
          values.each do |value|
            soap_request.add_node(node_attr(key, value))
          end
        end

        soap_request
      end

      def to_patch(hash)
        soap_request = SoapElement.admin(SoapAdminConstants::MODIFY_ACCOUNT_REQUEST)
                                  .add_attribute(SoapConstants::ID, @item.id)

        hash.each do |key, values|
          values = [values] unless values.is_a?(Array)
          values.each do |value|
            soap_request.add_node(node_attr(key, value))
          end
        end

        soap_request
      end

      def to_delete
        SoapElement.admin(SoapAdminConstants::DELETE_ACCOUNT_REQUEST).add_attribute('id', @item.id)
      end

      def to_rename(new_name)
        SoapElement.admin(SoapAdminConstants::RENAME_ACCOUNT_REQUEST)
                   .add_attributes({ id: @item.id, newName: new_name })
      end

      def attrs_only_set_h(selected_attrs)
        attrs_only_set = @item.instance_variables.map { |n| n.to_s[1..].to_sym } & selected_attrs

        Hash[attrs_only_set.map do |n|
          values = Utils.convert_bool_to_str(@item.send(n))
          values = [values].to_set unless values.is_a?(Array)
          [n, values]
        end]
      end

      private

      def node_attr(key, value)
        SoapElement.create(SoapConstants::A).add_attribute(SoapConstants::N, key).add_content(value)
      end
    end
  end
end
