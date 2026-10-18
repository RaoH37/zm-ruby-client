# frozen_string_literal: true

module Zm
  module Connector
    SSL_VERIFY_NONE = { verify: false, verify_hostname: false, verify_mode: OpenSSL::SSL::VERIFY_NONE }.freeze

    autoload :SoapBaseConnector, 'zm/connector/soap_base_connector'
    autoload :SoapAdminConnector, 'zm/connector/soap_admin_connector'
    autoload :SoapAccountConnector, 'zm/connector/soap_account_connector'
    autoload :RestConnector, 'zm/connector/rest_connector'
  end
end
