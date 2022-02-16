# frozen_string_literal: true

module Zm
  module Client
    # class for account collection folders jsns builder
    class FoldersJsnsBuilder
      def initialize(item)
        @item = item
      end

      def to_jsns
        {
          visible: @item.visible,
          needGranteeName: @item.needGranteeName,
          view: @item.view,
          depth: @item.depth,
          tr: @item.tr
        }.delete_if { |_, v| v.nil? }
      end
    end
  end
end
