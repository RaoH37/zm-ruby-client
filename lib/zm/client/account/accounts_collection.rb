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
        soap_request = SoapElement.admin(SoapAdminConstants::GET_ACCOUNT_REQUEST)
        node_account = SoapElement.create('account').add_attribute('by', hash.keys.first).add_content(hash.values.first)
        soap_request.add_node(node_account)
        soap_request.add_attribute('attrs', attrs_comma)
        soap_request.add_attribute('applyCos', @apply_cos)
        entry = sac.invoke(soap_request)[:GetAccountResponse][:account].first

        reset_query_params
        AccountJsnsInitializer.create(@parent, entry)
      end

      def quotas(domain_name: @domain_name, target_server_id: @target_server_id)
        return nil if domain_name.nil? && target_server_id.nil?

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

        soap_request = SoapElement.admin(SoapAdminConstants::GET_QUOTA_USAGE_REQUEST)
        soap_request.add_attributes(jsns)
        json = sac.invoke(soap_request)

        sac.context.target_server(nil) unless target_server_id.nil?

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
