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

      def zimbraMailHost
        @zimbraMailHost || zimbraMailHost!
      end

      def zimbraMailHost!
        return if @parent.name.nil? || @parent.id.nil?

        soap_request = SoapElement.account(SoapAccountConstants::GET_ACCOUNT_INFO_REQUEST)

        if @parent.id
          node_entry = SoapElement.create(SoapConstants::ACCOUNT).add_attribute(SoapConstants::BY, SoapConstants::ID).add_content(@parent.id)
        else
          node_entry = SoapElement.create(SoapConstants::ACCOUNT).add_attribute(SoapConstants::BY, SoapConstants::NAME).add_content(@parent.name)
        end

        soap_request.add_node(node_entry)
        @zimbraMailHost = @parent.sacc.invoke(soap_request).dig(:GetAccountInfoResponse, :_attrs, :zimbraMailHost)
      end

      private

      def build_response
        @all = make_query[:GetInfoResponse]
      end

      def make_query
        soap_request = SoapElement.account(SoapAccountConstants::GET_INFO_REQUEST).add_attributes(jsns)
        @parent.sacc.invoke(soap_request)
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
