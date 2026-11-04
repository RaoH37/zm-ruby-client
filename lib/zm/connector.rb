# frozen_string_literal: true

module Zm
  module Connector
    autoload :SSL_VERIFY_NONE, 'zm/connector/ssl'
    autoload :SSL_VERIFY_PEER, 'zm/connector/ssl'

    autoload :SoapBaseConnector, 'zm/connector/soap_base_connector'
    autoload :SoapAdminConnector, 'zm/connector/soap_admin_connector'
    autoload :SoapAccountConnector, 'zm/connector/soap_account_connector'
    autoload :RestConnector, 'zm/connector/rest_connector'
    autoload :NetworkErrorHandler, 'zm/connector/network_error_handler'
  end
end
