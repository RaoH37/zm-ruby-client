# frozen_string_literal: true

module Zm
  module Client
    # class for account contact jsns builder
    class ContactJsnsBuilder < BaseAccountJsnsBuilder
      EXCLUDE_INSTANCE_VARIABLE_KEYS = %i[@id @name @parent @l @type @tn @jsns_builder].freeze

      def to_jsns
        jsns = {
          cn: {
            a: instance_variables_array(all_instance_variables).map(&Utils::A_NODE_PROC),
            l: @item.folder_id || Zm::Client::FolderDefault::CONTACTS[:id]
          }
        }

        SoapElement.mail(SoapMailConstants::CREATE_CONTACT_REQUEST).add_attributes(jsns)
      end

      def to_update
        jsns = {
          cn: {
            a: instance_variables_array(all_instance_variables).map(&Utils::A_NODE_PROC),
            id: @item.id
          }
        }

        SoapElement.mail(SoapMailConstants::MODIFY_CONTACT_REQUEST).add_attributes(jsns)
      end

      def to_patch(hash)
        jsns = {
          cn: {
            id: @item.id,
            a: hash.map(&Utils::A_ARRAY_PROC).flatten(1).map(&Utils::A_NODE_PROC)
          }
        }

        SoapElement.mail(SoapMailConstants::MODIFY_CONTACT_REQUEST).add_attributes(jsns)
      end

      def instance_variables_array(zcs_attrs)
        arr = zcs_attrs.map do |name|
          n = name.to_s[1..]
          value = @item.instance_variable_get(name)
          [n, value]
        end

        multi_value = arr.select { |a| a.last.is_a?(Array) }
        arr.reject! { |a| a.last.is_a?(Array) || a.last.nil? }
        multi_value.each { |a| arr += a.last.map { |v| [a.first, v] } }
        arr
      end

      def all_instance_variables
        @item.instance_variables - EXCLUDE_INSTANCE_VARIABLE_KEYS
      end
    end
  end
end
