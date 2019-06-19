# frozen_string_literal: true

module Zm
  module Client
    # collection of shares
    class SharesCollection < Base::ObjectsCollection
      def initialize(parent)
        @parent = parent
        reset_query_params
      end

      def new(json)
        share = Share.new(@parent, json)
        yield(share) if block_given?
        share
      end

      private

      def build_response
        options = @owner_name.nil? ? {} : { owner: { by: :name, _content: @owner_name } }
        rep = @parent.sacc.get_share_info @parent.token, options
        sb = ShareBuilder.new @parent, rep
        sb.make
      end

      def reset_query_params
        @owner_name = nil
      end
    end
  end
end
