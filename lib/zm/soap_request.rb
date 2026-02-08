# frozen_string_literal: true

module Zm
  module SoapRequest
    autoload :SoapContext, 'zm/soap_request/soap_context'
    autoload :SoapAdminConstants, 'zm/soap_request/soap_admin_constants'
    autoload :SoapAccountConstants, 'zm/soap_request/soap_account_constants'
    autoload :SoapMailConstants, 'zm/soap_request/soap_mail_constants'
    autoload :SoapConstants, 'zm/soap_request/soap_constants'
    autoload :SoapElement, 'zm/soap_request/soap_element'
    autoload :RequestMethodsAdmin, 'zm/soap_request/request_methods_admin'
    autoload :RequestMethodsMailbox, 'zm/soap_request/request_methods_mailbox'
  end
end
