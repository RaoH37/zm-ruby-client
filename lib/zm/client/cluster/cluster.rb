require 'zm/client/connector/soap_admin'
require 'zm/client/connector/soap_account'
# require 'zm/client/data_source'
require 'zm/client/domain'
require 'zm/client/account'
# require 'zm/client/server'
# require 'zm/client/cos'
# require 'zm/client/distributionlist'

module Zm
  module Client
    class Cluster
      attr_reader :soap_admin_connector, :config

      def initialize(config)
        @config = config
        @soap_admin_connector = SoapAdminConnector.new(
          @config.zimbra_admin_scheme,
          @config.zimbra_admin_host,
          @config.zimbra_admin_port
        )
      end

      def login
        @soap_admin_connector.auth(
          @config.zimbra_admin_login,
          @config.zimbra_admin_password
        )
      end

      def soap_account_connector
        @soap_account_connector ||= SoapAccountConnector.new(
          @config.zimbra_public_scheme,
          @config.zimbra_public_host,
          @config.zimbra_public_port
        )
      end

      def domains
        @domains ||= DomainsCollection.new self
      end

      def accounts
        @accounts ||= AccountsCollection.new self
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

      def domain_key(domain_name)
        @config.domain_key(domain_name)
      end
    end
  end
end
