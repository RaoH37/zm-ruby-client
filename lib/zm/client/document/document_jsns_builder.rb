# frozen_string_literal: true

module Zm
  module Client
    # class for account document
    class DocumentJsnsBuilder < Base::BaseAccountJsnsBuilder
      def to_delete
        attrs = {
          op: :delete,
          comp: Zm::Utils::SearchUtils::OFF,
          id: @item.id
        }

        build(attrs)
      end
    end
  end
end
