module Zm
  module Client
    # objectClass: zimbraServer
    class Server < Base::AdminObject
      attr_accessor :name, :id

      # def accounts
      #   @accounts ||= AccountsCollection.new @soap_admin_connector
      # end

      # def quotas
      #   # todo
      #   rep = @soap_admin_connector.get_quota_usage(name, 1)
      #   AccountsBuilder.new(@soap_admin_connector, rep).make
      # end

      # def quotas!
      #   @accounts = quotas
      #   # todo il faudrait merger quotas dans @accounts
      # end
    end
  end
end
