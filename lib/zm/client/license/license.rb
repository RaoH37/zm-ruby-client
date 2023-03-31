# frozen_string_literal: true

module Zm
  module Client
    # objectClass: zimbraDomain
    class License < Base::AdminObject

      INSTANCE_VARIABLE_KEYS = %i[
        AccountsLimit ArchivingAccountsLimit AttachmentConversionEnabled AttachmentIndexingAccountsLimit BackupEnabled
        CrossMailboxSearchEnabled EwsAccountsLimit HierarchicalStorageManagementEnabled ISyncAccountsLimit InstallType
        IssuedOn IssuedToEmail IssuedToName LicenseId MAPIConnectorAccountsLimit MobileSyncAccountsLimit
        MobileSyncEnabled ResellerName SMIMEAccountsLimit TouchClientsAccountsLimit TwoFactorAuthAccountsLimit
        ValidFrom ValidUntil VoiceAccountsLimit ZSSAccountsLimit ZTalkAccountsLimit
      ]

      attr_accessor *INSTANCE_VARIABLE_KEYS

      def init_from_json(json)
        json[:attr].each do |a|
          instance_variable_set(arrow_name(a[:name]), a[:_content])
        end
      end

      def to_s
        INSTANCE_VARIABLE_KEYS.map { |v| [v, instance_variable_get(arrow_name(v))].join(' : ') }.join("\n")
      end
    end
  end
end
