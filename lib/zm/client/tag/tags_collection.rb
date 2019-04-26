module Zm
  module Client
    class TagsCollection < Base::ObjectsCollection
      def initialize(soap_account_connector, account)
        @soap_account_connector = soap_account_connector
        @account = account
      end

      def all
        rep = @soap_account_connector.get_tag(@account.token)
        tb = TagBuilder.new @account, rep
        tb.make
      end
    end
  end
end