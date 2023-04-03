# frozen_string_literal: true

module Zm
  module Client
    # collection of shares
    class SharesCollection < Base::ObjectsCollection
      def initialize(parent)
        @parent = parent
        reset_query_params
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
        @parent.sacc.jsns_request(:GetShareInfoRequest, @parent.token, build_options,
                                  SoapAccountConnector::ACCOUNTSPACE)
      end

      def share_builder
        ShareBuilder.new(@parent, share_response)
      end

      def build_options
        jsns = { includeSelf: 0 }
        return jsns if @owner_name.nil?

        jsns.merge!({ owner: { by: :name, _content: @owner_name } })
        jsns
      end

      def reset_query_params
        @owner_name = nil
      end
    end
  end
end
