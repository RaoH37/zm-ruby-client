# frozen_string_literal: true

module Zm
  module Client
    # class for account folder jsns builder
    class AceJsnsBuilder < Base::BaseJsnsBuilder
      def to_find
        return nil if @item.rights.empty?

        ace = @item.rights.map { |r| { right: r } }
        { ace: ace }
      end

      def to_jsns
        ace = {
          zid: @item.zid,
          gt: @item.gt,
          right: @item.right,
          d: @item.d
        }.reject { |_, v| v.nil? }

        { ace: ace }
      end

      def to_delete
        ace = {
          zid: @item.zid,
          gt: @item.gt,
          right: @item.right,
          d: @item.d
        }.reject { |_, v| v.nil? }

        { ace: ace }
      end
    end
  end
end
