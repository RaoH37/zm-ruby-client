# frozen_string_literal: true

module Zm
  module Client
    # Class Collection [Domain]
    class LicensesCollection
      def initialize(parent)
        @parent = parent
      end

      def find
        req = @parent.soap_admin_connector.jsns_request(:GetLicenseRequest, nil)
        entry = req[:Body][:GetLicenseResponse][:license].first
        LicenseJsnsInitializer.create(@parent, entry)
      end
    end
  end
end
