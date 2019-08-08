# frozen_string_literal: true

module Zm
  module Client
    # objectClass: zimbraDomain
    class License < Base::AdminObject
      attr_accessor :AccountsLimit, :ArchivingAccountsLimit, :AttachmentConversionEnabled, :AttachmentIndexingAccountsLimit, :BackupEnabled, :CrossMailboxSearchEnabled, :EwsAccountsLimit, :HierarchicalStorageManagementEnabled, :ISyncAccountsLimit, :InstallType, :IssuedOn, :IssuedToEmail, :IssuedToName, :LicenseId, :MAPIConnectorAccountsLimit, :MobileSyncAccountsLimit, :MobileSyncEnabled, :ResellerName, :SMIMEAccountsLimit, :TouchClientsAccountsLimit, :TwoFactorAuthAccountsLimit, :ValidFrom, :ValidUntil, :VoiceAccountsLimit, :ZSSAccountsLimit, :ZTalkAccountsLimit

      def init_from_json(json)
        json[:attr].each do |a|
          k = "@#{a[:name]}".to_sym
          instance_variable_set(k, a[:_content])
        end
      end
    end
  end
end
