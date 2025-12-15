# frozen_string_literal: true

module Zm
  module Client
    # Class Collection [Domain]
    class LicensesCollection
      def initialize(parent)
        @parent = parent
      end

      def find
        soap_request = SoapElement.admin(SoapAdminConstants::GET_LICENSE_REQUEST)
        entry = @parent.soap_admin_connector.invoke(soap_request)[:GetLicenseResponse][:license].first
        LicenseJsnsInitializer.create(@parent, entry)
      end
    end
  end
end
