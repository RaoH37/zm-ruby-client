# frozen_string_literal: true

module Zm
  module Client
    # class for account contact jsns builder
    class GroupContactJsnsBuilder < BaseAccountJsnsBuilder
      EXCLUDE_INSTANCE_VARIABLE_KEYS = %i[@id @name @parent @l @type @tn @jsns_builder].freeze

      # def initialize(item)
      #   @item = item
      # end

      def to_jsns
        {
          cn: {
            a: instance_variables_array.map(&Utils::A_NODE_PROC),
            l: @item.folder_id || Zm::Client::FolderDefault::CONTACTS[:id],
            m: members_node
          }
        }
      end

      def to_update
        {
          cn: {
            a: instance_variables_array.map(&Utils::A_NODE_PROC),
            id: @item.id,
            m: members_node
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

      # def to_delete
      #   { action: { op: :delete, id: @item.id } }
      # end
      #
      # def to_move
      #   { action: { op: :move, l: @item.l } }
      # end

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
