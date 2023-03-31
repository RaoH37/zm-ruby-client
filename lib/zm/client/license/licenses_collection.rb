# frozen_string_literal: true

module Zm
  module Client
    # Class Collection [Domain]
    class LicensesCollection
      def initialize(parent)
        @parent = parent
      end

      def find
        req = sac.get_license
        entry = req[:Body][:GetLicenseResponse][:license].first
        license = License.new(@parent)
        license.init_from_json(entry)
        license
      end

      private

      def soap_admin_connector
        @parent.soap_admin_connector
      end

      alias sac soap_admin_connector
    end
  end
end
