# frozen_string_literal: true

module Zm
  module Client
    # class for account document
    class DocumentJsnsBuilder < BaseAccountJsnsBuilder
      # def initialize(document)
      #   @document = document
      # end

      def to_delete
        action = {
         op: :delete,
         comp: 0,
         id: @item.id
        }

        { action: action }
      end

      # def to_delete
      #   {
      #    comp: 0,
      #    id: @document.id
      #   }
      # end
      #
      # def to_tag(tag_name)
      #   { action: { op: :tag, id: @document.id, tn: tag_name } }
      # end
      #
      # def to_move(new_folder_id)
      #   { action: { op: :move, id: @document.id, l: new_folder_id } }
      # end
      #
      # def to_delete
      #   { action: { op: :delete, id: @document.id } }
      # end
    end
  end
end
