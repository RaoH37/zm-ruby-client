# frozen_string_literal: true

require_relative 'soap_base'
require_relative 'soap_error'

module Zm
  module Client
    class SoapAdminConnector < SoapBaseConnector
      # ADMINSPACE = 'urn:zimbraAdmin'
      # A_NODE_PROC = ->(n) { { n: n.first, _content: n.last } }

      class << self
        def create(config)
          trans = new(
            config.zimbra_admin_scheme,
            config.zimbra_admin_host,
            config.zimbra_admin_port
          )
          trans.logger = config.logger
          trans
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

      # def init_hash_request(soap_name, target_server = nil)
      #   {
      #     Body: {
      #       soap_name => { _jsns: ADMINSPACE }
      #     }
      #   }.merge(hash_header(token, target_server))
      # end
    end
  end
end
