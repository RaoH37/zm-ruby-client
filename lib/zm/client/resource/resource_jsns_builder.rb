# frozen_string_literal: true

module Zm
  module Client
    # class for resource jsns builder
    class ResourceJsnsBuilder < Base::BaseJsnsBuilder
      def to_jsns
        req = {
          name: @item.name,
          password: @item.password
        }.reject { |_, v| v.nil? }

        req[:a] = instance_variables_array.map(&A_ARRAY_PROC).flatten(1).map(&A_NODE_PROC)

        req
      end
    end
  end
end
