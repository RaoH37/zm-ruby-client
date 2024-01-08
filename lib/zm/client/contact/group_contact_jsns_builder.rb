# frozen_string_literal: true

module Zm
  module Client
    # class for account contact jsns builder
    class GroupContactJsnsBuilder < BaseAccountJsnsBuilder
      EXCLUDE_INSTANCE_VARIABLE_KEYS = %i[@id @name @parent @l @type @tn @jsns_builder].freeze

      def to_jsns
        {
          cn: {
            a: instance_variables_array.map(&Utils::A_NODE_PROC),
            l: @item.folder_id || Zm::Client::FolderDefault::CONTACTS[:id],
            m: members_node
          }
        }

        SoapElement.mail(SoapMailConstants::CREATE_CONTACT_REQUEST).add_attributes(jsns)
      end

      def to_update
        jsns = {
          cn: {
            a: instance_variables_array.map(&Utils::A_NODE_PROC),
            id: @item.id,
            m: members_node
          }
        }

        SoapElement.mail(SoapMailConstants::MODIFY_CONTACT_REQUEST).add_attributes(jsns)
      end

      def to_patch(hash)
        {
          cn: {
            id: @item.id,
            a: hash.map(&Utils::A_ARRAY_PROC).flatten(1).map(&Utils::A_NODE_PROC)
          }
        }

        SoapElement.mail(SoapMailConstants::MODIFY_CONTACT_REQUEST).add_attributes(jsns)
      end

      alias to_create to_jsns

      def members_node
        @item.members.all.reject(&:current?).map do |m|
          { type: m.type, value: m.value, op: m.op }
        end
      end

      def instance_variables_array
        [[:nickname, @item.name], [:fullname, @item.name], [:fileAs, "8:#{@item.name}"], %i[type group]]
      end
    end
  end
end
