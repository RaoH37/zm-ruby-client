# frozen_string_literal: true

module Zm
  module Client
    # resolves the 3.0 constant names moved out of Zm::Client, with a deprecation warning
    module DeprecatedConstants
      NAMES = {
        ZmError: 'Zm::Error::ZmError',
        SoapError: 'Zm::Error::SoapError',
        AuthError: 'Zm::Error::AuthError',
        RestError: 'Zm::Error::RestError',
        SoapBaseConnector: 'Zm::Connector::SoapBaseConnector',
        SoapAdminConnector: 'Zm::Connector::SoapAdminConnector',
        SoapAccountConnector: 'Zm::Connector::SoapAccountConnector',
        RestConnector: 'Zm::Connector::RestConnector',
        SoapElement: 'Zm::SoapRequest::SoapElement',
        SoapConstants: 'Zm::SoapRequest::SoapConstants',
        SoapAdminConstants: 'Zm::SoapRequest::SoapAdminConstants',
        SoapAccountConstants: 'Zm::SoapRequest::SoapAccountConstants',
        SoapMailConstants: 'Zm::SoapRequest::SoapMailConstants',
        SoapUtils: 'Zm::Utils::SearchUtils',
        Regex: 'Zm::Utils::Regex',
        ContentType: 'Zm::Utils::ContentType',
        ContentPart: 'Zm::Utils::ContentPart'
      }.freeze

      def const_missing(name)
        target = NAMES[name]
        return super if target.nil?

        warn("#{self}::#{name} is deprecated and will be removed in 4.0, use #{target} instead", uplevel: 1)
        const_set(name, Object.const_get(target))
      end
    end
  end
end
