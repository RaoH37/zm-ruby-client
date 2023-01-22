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

      def where(owner_name: nil)
        @owner_name = owner_name
        self
      end

      private

      def build_response
        share_builder.make
      end

      def share_response
        @parent.sacc.get_share_info @parent.token, build_options
      end

      def share_builder
        ShareBuilder.new(@parent, share_response)
      end

      def build_options
        return {} if @owner_name.nil?

        { owner: { by: :name, _content: @owner_name } }
      end

      def reset_query_params
        @owner_name = nil
      end
    end
  end
end
