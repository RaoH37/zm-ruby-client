# frozen_string_literal: true

module Zm
  module Utils
    module HasSoapAdminConnector
      def soap_admin_connector
        @parent.soap_admin_connector
      end
      alias sac soap_admin_connector
    end
  end
end
