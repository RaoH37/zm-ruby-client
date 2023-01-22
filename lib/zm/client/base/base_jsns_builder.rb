# frozen_string_literal: true

module Zm
  module Client
    module Base
      # class for account object jsns builder
      class BaseJsnsBuilder
        A_ARRAY_PROC = ->(i) { i.last.is_a?(Array) ? i.last.map { |j| [i.first, j] } : [i] }
        A_NODE_PROC = ->(n) { { n: n.first, _content: n.last } }

        def initialize(item)
          @item = item
        end

        def to_jsns
          {
            name: @item.name,
            a: instance_variables_array.map(&A_ARRAY_PROC).flatten(1).map(&A_NODE_PROC)
          }
        end

        alias to_create to_jsns

        def to_update
          {
            id: @item.id,
            a: instance_variables_array.map(&A_ARRAY_PROC).flatten(1).map(&A_NODE_PROC)
          }
        end

        def to_patch(hash)
          {
            id: @item.id,
            a: hash.map(&A_ARRAY_PROC).flatten(1).map(&A_NODE_PROC)
          }
        end

        def to_delete
          { id: @item.id }
        end

        def instance_variables_array
          selected_attrs = @item.attrs_write.map { |a| arrow_name(a).to_sym }
          attrs_only_set = @item.instance_variables & selected_attrs

          arr = attrs_only_set.map do |name|
            n = name.to_s[1..]
            value = @item.instance_variable_get(name)
            [n, value]
          end

          multi_value = arr.select { |a| a.last.is_a?(Array) }
          arr.reject! { |a| a.last.is_a?(Array) || a.last.nil? }
          multi_value.each { |a| arr += a.last.map { |v| [a.first, v] } }
          arr
        end

        def arrow_name(name)
          return name if name.to_s.start_with?('@')

          "@#{name}"
        end
      end
    end
  end
end
