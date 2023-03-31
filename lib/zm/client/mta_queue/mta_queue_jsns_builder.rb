# frozen_string_literal: true

module Zm
  module Client
    # class for account folder jsns builder
    class MtaQueueJsnsBuilder < Base::BaseJsnsBuilder
      def to_jsns(op, ids)
        {
          server: {
            name: @item.server.name,
            queue: {
              name: @item.name,
              action: {
                op: op,
                by: :id,
                _content: ids.join(',')
              }
            }
          }
        }
      end

      def to_list
        query = {
          offset: @item.offset,
          limit: @item.limit
        }
        query[:field] = @item.fields.map { |k, v| { name: k, match: { value: v } } } unless @item.fields.empty?
        query.reject! { |_, v| v.nil? || v.empty? }

        {
          server: {
            name: @item.server.name,
            queue: {
              name: @item.mta_queue.name,
              scan: 1,
              query: query
            }
          }
        }
      end
    end
  end
end
