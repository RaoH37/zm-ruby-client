# frozen_string_literal: true

module Zm
  module Client
    # class for account collection folders jsns builder
    class FoldersJsnsBuilder
      def initialize(item)
        @item = item
      end

      def to_jsns
        attrs = {
          visible: @item.visible,
          needGranteeName: @item.needGranteeName,
          view: @item.view,
          depth: @item.depth,
          tr: @item.tr
        }.compact

        SoapElement.mail(SoapMailConstants::GET_FOLDER_REQUEST)
                   .add_attributes(attrs)
      end
    end
  end
end
