module Zm
  module Client
    module Base
      # Abstract Class Provisionning AdminObject
      class AdminObject < Object

        def soap_admin_connector
          @parent.soap_admin_connector
        end

        alias sac soap_admin_connector

        def soap_account_connector
          @parent.soap_account_connector
        end

        alias sacc soap_account_connector
      end
    end
  end
end
