# frozen_string_literal: true

module Zm
  module Client
    # Collection Accounts
    class AccountsCollection < Base::AdminObjectsCollection
      ONERRORS = %w[continue stop].freeze

      def initialize(parent)
        @child_class = Account
        @builder_class = AccountsBuilder
        @search_type = :accounts
        super
      end

      def find_by!(hash)
        entry = sac.invoke(build_find_by(hash))[:GetAccountResponse][:account].first

        reset_query_params
        AccountJsnsInitializer.create(@parent, entry)
      end

      def build_find_by(hash)
        soap_request = SoapRequest::SoapElement.admin(Zm::SoapRequest::SoapAdminConstants::GET_ACCOUNT_REQUEST)
        node_account = SoapRequest::SoapElement.create(SoapRequest::SoapConstants::ACCOUNT)
                                  .add_attribute(SoapRequest::SoapConstants::BY, hash.keys.first)
                                  .add_content(hash.values.first)
        soap_request.add_node(node_account)
        soap_request.add_attribute(SoapRequest::SoapConstants::ATTRS, attrs_comma)
        soap_request.add_attribute(SoapRequest::SoapConstants::APPLY_COS, @apply_cos)
        soap_request
      end

      def quotas(domain_name: @domain_name, target_server_id: @target_server_id)
        return nil if domain_name.nil? && target_server_id.nil?

        if target_server_id.nil?
          @all_servers = Zm::Utils::SearchUtils::ON
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
        }
        jsns.compact!

        soap_request = SoapRequest::SoapElement.admin(Zm::SoapRequest::SoapAdminConstants::GET_QUOTA_USAGE_REQUEST)
                                  .add_attributes(jsns)
        json = sac.invoke(soap_request)

        sac.context.target_server(nil) unless target_server_id.nil?

        reset_query_params
        @builder_class.new(@parent, json).make
      end

      def update_all!(hash, onerror: ONERRORS.first, update_attributes: true)
        mass_update!(build_response, hash, onerror:, update_attributes:)
      end

      def mass_update!(accounts, hash, onerror: ONERRORS.first, update_attributes: true)
        format_mass_accounts_parameter(accounts)

        accounts.each do |account|
          account.update!(hash, update_attributes:)
        rescue Zm::Client::SoapError => e
          @parent.logger.error e.message
          @parent.logger.debug e.backtrace.join("\n")

          return accounts if onerror == ONERRORS.last
        end

        accounts
      end

      private

      def format_mass_accounts_parameter(accounts)
        accounts.map! do |account|
          if account.is_a?(@child_class)
            account.updated = false
            account
          else
            new { |acc| acc.id = account }
          end
        end
      end

      def reset_query_params
        super
        @attrs = %w[
          displayName
          zimbraId
          cn
          sn
          zimbraMailHost
          uid
          zimbraCOSId
          zimbraAccountStatus
          zimbraLastLogonTimestamp
          description
          zimbraIsSystemAccount
          zimbraIsDelegatedAdminAccount
          zimbraAuthTokenValidityValue
          zimbraMailStatus
          zimbraIsAdminAccount
          zimbraIsExternalVirtualAccount
        ]
      end
    end
  end
end
