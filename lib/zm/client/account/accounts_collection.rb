# frozen_string_literal: true

module Zm
  module Client
    # Collection Accounts
    class AccountsCollection < Base::ObjectsCollection
      def initialize(parent)
        @parent = parent
        # puts "AccountsCollection initialize #{@parent.class} #{@parent.object_id} #{@parent.soap_admin_connector}"
        reset_query_params
      end

      def find_by(hash, *attrs)
        rep = sac.get_account(hash.values.first, hash.keys.first, attrs.join(COMMA))
        entry = rep[:Body][:GetAccountResponse][:account].first
        # puts "AccountsCollection find_by #{@parent.class} #{@parent.object_id} #{@parent.soap_admin_connector}"
        account = Account.new(@parent)
        account.init_from_json(entry)
        account
      end

      private

      def build_response
        AccountsBuilder.new(@parent, make_query).make
      end

      def reset_query_params
        super
        @search_type = SearchType::ACCOUNT
        @attrs = SearchType::Attributes::ACCOUNT
      end
    end
  end
end
