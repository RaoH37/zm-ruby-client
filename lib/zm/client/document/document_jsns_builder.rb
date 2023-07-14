# frozen_string_literal: true

module Zm
  module Client
    # class for account document
    class DocumentJsnsBuilder < BaseAccountJsnsBuilder
      def to_delete
        attrs = {
          op: :delete,
          comp: 0,
          id: @item.id
        }

        build(attrs)
      end
    end
  end
end
