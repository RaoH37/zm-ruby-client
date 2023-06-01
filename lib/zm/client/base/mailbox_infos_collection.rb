# frozen_string_literal: true

module Zm
  module Client
    class MailboxInfosCollection
      def initialize(parent)
        @parent = parent
        @sections = []
        @rights = []
      end

      def all
        @all || all!
      end

      def all!
        build_response
      end

      def clear
        reset_query_params
        @all.clear
      end

      def sections(*entries)
        @sections += entries
        self
      end

      def rights(*entries)
        @rights += entries
        self
      end

      def read
        reset_query_params
        @sections = ['mbox']
        rep = build_response
        @parent.id = rep[:id]
        @parent.used = rep[:used]
        @parent.public_url = rep[:publicURL]
        @parent.zimbraCOSId = rep[:cos][:id]
        @parent.home_url = rep[:rest]
        rep
      end

      private

      def build_response
        @all = make_query.dig(:Body, :GetInfoResponse)
      end

      def make_query
        @parent.sacc.jsns_request(:GetInfoRequest, @parent.token, jsns, SoapAccountConnector::ACCOUNTSPACE)
      end

      def jsns
        { rights: @rights.join(','), sections: @sections.join(',') }.reject { |_, v| v.empty? }
      end

      def reset_query_params
        @sections.clear
        @rights.clear
      end
    end
  end
end
