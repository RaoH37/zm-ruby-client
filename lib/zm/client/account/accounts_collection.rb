# frozen_string_literal: true

module Zm
  module Client
    # Collection Accounts
    class AccountsCollection < Base::AdminObjectsCollection
      def initialize(parent)
        @child_class = Account
        @builder_class = AccountsBuilder
        @search_type = SearchType::ACCOUNT
        super(parent)
      end

      def find_by!(hash)
        rep = sac.get_account(hash.values.first, hash.keys.first, attrs_comma, @apply_cos)
        entry = rep[:Body][:GetAccountResponse][:account].first

        reset_query_params
        AccountJsnsInitializer.create(@parent, entry)
      end

      def quotas
        return nil if @domain_name.nil? && @target_server_id.nil?

        json = sac.get_quota_usage(@domain_name, @all_servers, @limit, @offset, @sort_by, @sort_ascending, @refresh,
                                   @target_server_id)
        reset_query_params
        @builder_class.new(@parent, json).make
      end

      private

      def reset_query_params
        super
        @attrs = SearchType::Attributes::ACCOUNT.dup
      end
    end
  end
end
