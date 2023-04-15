# frozen_string_literal: true

module Zm
  module Client
    # class for account document
    class DocumentJsnsBuilder < BaseAccountJsnsBuilder
      def to_delete
        action = {
          op: :delete,
          comp: 0,
          id: @item.id
        }

        { action: action }
      end
    end
  end
end
