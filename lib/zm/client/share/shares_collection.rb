module Zm
  module Client
    class SharesCollection < Base::ObjectsCollection

      def initialize(soap_account_connector, account)
        @soap_account_connector = soap_account_connector
        @account = account
      end

      def new(json)
        share = Share.new(@account, json)
        yield(share) if block_given?
        share
      end

      def all
        @all_shares || where
      end

      def all!
        where!
      end

      def where(name = nil)
        options = name.nil? ? {} : {owner: {by: :name, _content: name}}
        rep = @soap_account_connector.get_share_info @account.token, options
        sb = ShareBuilder.new @account, rep
        sb.make
      end

      def where!(name = nil)
        @all_shares = where(name)
      end
    end
  end
end