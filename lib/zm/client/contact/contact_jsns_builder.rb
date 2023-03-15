# frozen_string_literal: true

module Zm
  module Client
    # class for account contact jsns builder
    class ContactJsnsBuilder
      EXCLUDE_INSTANCE_VARIABLE_KEYS = %i[@id @name @parent @l @type @tn @jsns_builder].freeze

      def initialize(item)
        @item = item
      end

      def to_jsns
        {
          cn: {
            a: instance_variables_array(all_instance_variables).map(&Utils::A_ARRAY_PROC).map(&Utils::A_NODE_PROC),
            l: @item.folder_id || Zm::Client::FolderDefault::CONTACTS[:id]
          }
        }
      end

      def to_update
        {
          cn: {
            a: instance_variables_array(all_instance_variables).map(&Utils::A_ARRAY_PROC).map(&Utils::A_NODE_PROC),
            id: @item.id
          }
        }
      end

      def to_patch(hash)
        {
          cn: {
            id: @item.id,
            a: hash.map(&Utils::A_ARRAY_PROC).flatten(1).map(&Utils::A_NODE_PROC)
          }
        }
      end

      def to_delete
        { action: { op: :delete, id: @item.id } }
      end

      def to_move
        { action: { op: :move, l: @item.l } }
      end

      alias to_create to_jsns

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
