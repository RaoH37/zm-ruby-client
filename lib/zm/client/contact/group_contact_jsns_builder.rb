# frozen_string_literal: true

module Zm
  module Client
    # class for account contact jsns builder
    class GroupContactJsnsBuilder < Base::BaseAccountJsnsBuilder
      def to_jsns
        jsns = {
          cn: {
            a: instance_variables_array.map(&Utils::A_NODE_PROC),
            l: @item.l || Zm::Client::FolderDefault::CONTACTS.id,
            m: new_members_node
          }
        }

        SoapRequest::SoapElement.mail(SoapRequest::SoapMailConstants::CREATE_CONTACT_REQUEST)
                                .add_attributes(jsns)
      end

      def to_update
        jsns = {
          cn: {
            a: instance_variables_array.map(&Utils::A_NODE_PROC),
            id: @item.id,
            m: members_node
          }
        }

        SoapRequest::SoapElement.mail(SoapRequest::SoapMailConstants::MODIFY_CONTACT_REQUEST)
                                .add_attributes(jsns)
      end

      def to_patch(hash)
        jsns = {
          cn: {
            id: @item.id,
            a: hash.flat_map(&Utils::A_ARRAY_PROC).map(&Utils::A_NODE_PROC)
          }
        }

        SoapRequest::SoapElement.mail(SoapRequest::SoapMailConstants::MODIFY_CONTACT_REQUEST)
                                .add_attributes(jsns)
      end

      alias to_create to_jsns

      def new_members_node
        @item.members.all.reject { |m| m.op == ContactMember::DEL }.map do |m|
          { type: m.type, value: m.value }
        end
      end

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
