# frozen_string_literal: true

module Zm
  module Client
    # objectClass: License
    class License < Base::Object
      attr_accessor :AccountsLimit, :ArchivingAccountsLimit, :AttachmentConversionEnabled,
                    :AttachmentIndexingAccountsLimit, :BackupEnabled, :CrossMailboxSearchEnabled, :EwsAccountsLimit,
                    :HierarchicalStorageManagementEnabled, :ISyncAccountsLimit, :InstallType, :IssuedOn,
                    :IssuedToEmail, :IssuedToName, :LicenseId, :MAPIConnectorAccountsLimit, :MobileSyncAccountsLimit,
                    :MobileSyncEnabled, :ResellerName, :SMIMEAccountsLimit, :TouchClientsAccountsLimit,
                    :TwoFactorAuthAccountsLimit, :ValidFrom, :ValidUntil, :VoiceAccountsLimit, :ZSSAccountsLimit,
                    :ZTalkAccountsLimit, :AttachmentIndexingEnabled, :BasicOneToOneChatAccountsLimit, 
                    :BriefcaseAccountsLimit, :CalenderAccountsLimit, :ChatAccountsLimit, :ChatVideoAccountsLimit,
                    :ConversationEnabledAccountsLimit, :DelegatedAdminAccountsLimit, :DocumentEditingAccountsLimit,
                    :FeaturesOnHold, :GroupCalenderAccountsLimit, :ManageZimletsEnabledAccountsLimit,
                    :MultiFactorAuthEnabled, :ObjectStoreSupportEnabled, :SharingAccountsLimit,
                    :StorageManagementEnabled, :TaggingEnabledAccountsLimit, :TaskEnabledAccountsLimit,
                    :ViewInHtmlEnabledAccountsLimit
    end
  end
end
