# frozen_string_literal: true

require 'zm/client/connector/soap_admin'
require 'zm/client/connector/soap_account'
require 'zm/client/common'
require 'zm/client/account'
require 'zm/client/resource'
require 'zm/client/distributionlist'
require 'zm/client/domain'
require 'zm/client/server'
require 'zm/client/cos'
require 'zm/client/license'

module Zm
  module Client
    # class admin connection
    class Cluster
      attr_reader :soap_admin_connector, :config, :zimbra_attributes, :type, :version, :release, :buildDate, :host,
                  :majorversion, :minorversion, :microversion

      def initialize(config)
        # extend(ZmLogger)

        @config = config
        @version = config.zimbra_version

        @zimbra_attributes = Base::ZimbraAttributesCollection.new(self)
        @zimbra_attributes.set_methods

        @soap_admin_connector = SoapAdminConnector.create(@config)
      end

      def has_admin_credentials?
        @config.has_admin_credentials?
      end

      def login
        raise ClusterConfigError, 'admin credentials are missing' unless @config.has_admin_credentials?

        logger.info 'Get Admin session token'
        @soap_admin_connector.auth(
          @config.zimbra_admin_login,
          @config.zimbra_admin_password
        )
      end

      def logged?
        !@soap_admin_connector.token.nil?
      end

      def alive?
        @soap_admin_connector.jsns_request(:NoOpRequest, nil)
        true
      rescue Zm::Client::SoapError => e
        logger.error "Admin session token alive ? #{e.message}"
        false
      end

      def token_metadata
        @token_metadata ||= TokenMetaData.new(@soap_admin_connector.token)
      end

      def license
        @license ||= LicensesCollection.new(self).find
      rescue Zm::Client::SoapError => e
        logger.error "Get License info #{e.message}"
        nil
      end

      def domains
        @domains ||= DomainsCollection.new self
      end

      def accounts
        @accounts ||= AccountsCollection.new self
      end

      def resources
        @resources ||= ResourcesCollection.new self
      end

      def servers
        @servers ||= ServersCollection.new self
      end

      def coses
        @coses ||= CosesCollection.new self
      end

      def distributionlists
        @distributionlists ||= DistributionListsCollection.new self
      end

      alias distribution_lists distributionlists

      def domain_key(domain_name)
        key = @config.domain_key(domain_name)
        key ||= find_domain_key(domain_name)
        key
      end

      def count_object(type)
        raise ZmError, 'Unknown object type' unless Zm::Client::CountTypes::ALL.include?(type)

        resp = soap_admin_connector.jsns_request(:CountObjectsRequest, { type: type })
        resp[:Body][:CountObjectsResponse][:num]
      end

      def email_exist?(email)
        jsns = {
          query: "(mail=#{email})",
          types: 'accounts,distributionlists,aliases,resources',
          countOnly: SoapUtils::ON
        }

        resp = soap_admin_connector.jsns_request(:SearchDirectoryRequest, jsns)
        num = resp[:Body][:SearchDirectoryResponse][:num]
        !num.zero?
      end

      def infos!
        rep = soap_admin_connector.jsns_request(:GetVersionInfoRequest, nil)
        json = rep[:Body][:GetVersionInfoResponse][:info].first

        instance_variable_set(:@type, json[:type])
        instance_variable_set(:@version, json[:version])
        instance_variable_set(:@release, json[:release])
        instance_variable_set(:@buildDate, json[:buildDate])
        instance_variable_set(:@host, json[:host])
        instance_variable_set(:@majorversion, json[:majorversion])
        instance_variable_set(:@minorversion, json[:minorversion])
        instance_variable_set(:@microversion, json[:microversion])
      end

      private

      def find_domain_key(domain_name)
        domains.attrs('zimbraPreAuthKey').find_by(name: domain_name).zimbraPreAuthKey
      end

      def logger
        @config.logger
      end
    end
  end
end
