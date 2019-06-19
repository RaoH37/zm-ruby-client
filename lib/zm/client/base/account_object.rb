# frozen_string_literal: true

module Zm
  module Client
    module Base
      # Abstract Class Provisionning AccountObject
      class AccountObject < Object

        def soap_account_connector
          @parent.soap_account_connector
        end

        alias sacc soap_account_connector
      end
    end
  end
end
