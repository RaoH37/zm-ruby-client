# frozen_string_literal: true

module Zm
  module Client
    # Collection Accounts
    class AccountsCollection < Base::ObjectsCollection
      def initialize(parent)
        @parent = parent
        reset_query_params
      end

      def ldap
        @apply_cos = 0
        self
      end

      def find_by(hash)
        rep = sac.get_account(hash.values.first, hash.keys.first, attrs_comma, @apply_cos)
        reset_query_params
        entry = rep[:Body][:GetAccountResponse][:account].first

        account = Account.new(@parent)
        account.init_from_json(entry)
        account
      end

      def find_all_quotas(domain_name = nil, target_server_id = nil)
        json = sac.get_quota_usage(domain_name, @all_servers, @limit, @offset, @sort_by, @sort_ascending, @refresh, target_server_id)
        reset_query_params
        AccountsBuilder.new(@parent, json).make
      end

      private

      def build_response
        AccountsBuilder.new(@parent, make_query).make
      end

      def reset_query_params
        super
        @search_type = SearchType::ACCOUNT
        @attrs = SearchType::Attributes::ACCOUNT.dup
        @all_servers = 1
        @refresh = 0
        @apply_cos = 1
      end
    end
  end
end
