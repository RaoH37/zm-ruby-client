# frozen_string_literal: true

module Zm
  module Client
    # class for cos folder jsns builder
    class CosJsnsBuilder < Base::BaseJsnsBuilder
      def to_jsns
        {
          name: { _content: @item.name },
          a: instance_variables_array.map(&A_ARRAY_PROC).flatten(1).map(&A_NODE_PROC)
        }
      end

      def to_update
        {
          id: { _content: @item.id },
          a: instance_variables_array.map(&A_ARRAY_PROC).flatten(1).map(&A_NODE_PROC)
        }
      end

      def to_patch(hash)
        {
          id: { _content: @item.id },
          a: hash.map(&A_ARRAY_PROC).flatten(1).map(&A_NODE_PROC)
        }
      end
    end
  end
end
