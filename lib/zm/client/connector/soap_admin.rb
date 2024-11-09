# frozen_string_literal: true

require_relative 'soap_base'
require_relative 'soap_error'

module Zm
  module Client
    class SoapAdminConnector < SoapBaseConnector
      class << self
        def create(config)
          new(
            config.zimbra_admin_scheme,
            config.zimbra_admin_host,
            config.zimbra_admin_port
          ).tap do |trans|
            trans.logger = config.logger
            trans.cache = config.cache_store
          end
        end
      end

      def token
        context.to_hash[:authToken]
      end

      def token=(value)
        context.token(value)
      end

      def initialize(scheme, host, port)
        super(scheme, host, port, SoapAdminConstants::ADMIN_SERVICE_URI)
      end
    end
  end
end
