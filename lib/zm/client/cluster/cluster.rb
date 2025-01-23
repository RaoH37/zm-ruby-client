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
require 'zm/client/cluster/batch_request'


module Zm
  module Client
    # class admin connection
    class Cluster
      attr_reader :soap_admin_connector, :config, :zimbra_attributes, :type, :version, :release, :buildDate, :host,
                  :majorversion, :minorversion, :microversion

      def initialize(config)
        @config = config
        @version = config.zimbra_version

        @zimbra_attributes = Base::ZimbraAttributesCollection.new(self)
        @zimbra_attributes.set_methods

        @soap_admin_connector = SoapAdminConnector.create(@config)
      end

      def has_admin_credentials?
        @config.has_admin_credentials?
      end

      def token
        @token ||= (Token.new(@soap_admin_connector.token) if @soap_admin_connector.token)
      end

      def token=(value)
        @token = Token.new(@soap_admin_connector.token = value)
      end

      def login
        raise ClusterConfigError, 'admin credentials are missing' unless @config.has_admin_credentials?

        logger.info 'Get Admin session token'

        @soap_admin_connector.token = nil if logged?

        soap_request = SoapElement.admin(SoapAdminConstants::AUTH_REQUEST)
        soap_request.add_attributes(name: @config.zimbra_admin_login, password: @config.zimbra_admin_password)
        soap_resp = @soap_admin_connector.invoke(soap_request, Zm::Client::AuthError)
        soap_resp_token = soap_resp[:AuthResponse][:authToken].first[:_content]
        self.token = soap_resp_token
      end

      def logged?
        !token.nil? && !token.expired?
      end

      def alive?
        soap_request = SoapElement.admin(SoapAdminConstants::NO_OP_REQUEST)
        @soap_admin_connector.invoke(soap_request)
        true
      rescue Zm::Client::SoapError => e
        logger.error "Admin session token alive ? #{e.message}"
        false
      end

      def logged_and_alive?
        logged? && alive?
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

        soap_request = SoapElement.admin(SoapAdminConstants::COUNT_OBJECTS_REQUEST)
        soap_request.add_attribute('type', type)
        soap_resp = @soap_admin_connector.invoke(soap_request)
        soap_resp[:CountObjectsResponse][:num]
      end

      def email_exist?(email)
        jsns = {
          query: "(mail=#{email})",
          types: 'accounts,distributionlists,aliases,resources',
          countOnly: SoapUtils::ON
        }

        soap_request = SoapElement.admin(SoapAdminConstants::SEARCH_DIRECTORY_REQUEST)
        soap_request.add_attributes(jsns)
        soap_resp = @soap_admin_connector.invoke(soap_request)
        !soap_resp[:SearchDirectoryResponse][:num].zero?
      end

      def infos!
        soap_request = SoapElement.admin(SoapAdminConstants::GET_VERSION_INFO_REQUEST)
        soap_response = @soap_admin_connector.invoke(soap_request)

        json = soap_response[:GetVersionInfoResponse][:info].first

        instance_variable_set(:@type, json[:type])
        instance_variable_set(:@version, json[:version])
        instance_variable_set(:@release, json[:release])
        instance_variable_set(:@buildDate, json[:buildDate])
        instance_variable_set(:@host, json[:host])
        instance_variable_set(:@majorversion, json[:majorversion])
        instance_variable_set(:@minorversion, json[:minorversion])
        instance_variable_set(:@microversion, json[:microversion])
      end

      def logger
        @config.logger
      end

      def batch
        return @batch if defined? @batch

        @batch = BatchRequest.new(self)
      end

      private

      def find_domain_key(domain_name)
        domains.attrs('zimbraPreAuthKey').find_by(name: domain_name).zimbraPreAuthKey
      end
    end
  end
end
