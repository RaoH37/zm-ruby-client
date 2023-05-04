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
        # rep = sac.get_account(hash.values.first, hash.keys.first, attrs_comma, @apply_cos)
        # entry = rep[:Body][:GetAccountResponse][:account].first

        soap_request = SoapElement.new(SoapAdminConstants::GET_ACCOUNT_REQUEST, SoapAdminConstants::NAMESPACE_STR)
        node_account = SoapElement.new('account', nil).add_attribute('by', hash.keys.first).add_content(hash.values.first)
        soap_request.add_node(node_account)
        soap_request.add_attribute('attrs', attrs_comma)
        soap_request.add_attribute('applyCos', @apply_cos)
        entry = sac.invoke(soap_request)[:GetAccountResponse][:account].first

        reset_query_params
        AccountJsnsInitializer.create(@parent, entry)
      end

      def quotas(domain_name: @domain_name, target_server_id: @target_server_id)
        return nil if domain_name.nil? && target_server_id.nil?

        # json = sac.get_quota_usage(@domain_name, @all_servers, @limit, @offset, @sort_by, @sort_ascending, @refresh,
        #                            @target_server_id)
        if target_server_id.nil?
          @all_servers = SoapUtils::ON
        else
          sac.context.target_server(target_server_id)
        end

        jsns = {
          domain: domain_name,
          allServers: @all_servers,
          limit: @limit,
          offset: @offset,
          sortBy: @sort_by,
          sortAscending: @sort_ascending,
          refresh: @refresh
        }.delete_if { |_, value| value.nil? }

        soap_request = SoapElement.new(SoapAdminConstants::GET_QUOTA_USAGE_REQUEST, SoapAdminConstants::NAMESPACE_STR)
        soap_request.add_attributes(jsns)
        json = sac.invoke(soap_request)

        sac.context.target_server(nil) unless target_server_id.nil?

        puts json

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
