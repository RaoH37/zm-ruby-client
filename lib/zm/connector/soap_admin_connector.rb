# frozen_string_literal: true

module Zm
  module Connector
    class SoapAdminConnector < SoapBaseConnector
      class << self
        def create(config)
          new(
            config.zimbra_admin_url
          ).tap do |trans|
            trans.logger = config.logger
            trans.cache = config.cache
            trans.timeout = config.timeout
          end
        end
      end

      def token
        context.to_hash[:authToken]
      end

      def token=(value)
        context.token(value)
      end

      def initialize(url)
        super(url, Zm::SoapRequest::SoapAdminConstants::ADMIN_SERVICE_URI)
      end
    end
  end
end
