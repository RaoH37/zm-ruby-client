# frozen_string_literal: true

module Zm
  module Client
    # objectClass: zimbraCos
    class Cos < Base::Object
      extend Relationship
      has_jsns_builder

      include Zm::Utils::HasSoapAdminConnector
      extend Base::HasZimbraAttributes

      zimbra_attr %i[
        cn description zimbraNotes zimbraMailQuota zimbraPrefSaveToSent zimbraPasswordMinLength zimbraPasswordMaxLength
        zimbraPasswordMinAge zimbraPasswordMaxAge zimbraPasswordEnforceHistory zimbraPasswordLocked
        zimbraPrefGroupMailBy zimbraPrefIncludeSpamInSearch zimbraPrefIncludeTrashInSearch zimbraPrefMailItemsPerPage
        zimbraPrefUseKeyboardShortcuts zimbraPrefMailInitialSearch zimbraPrefSentMailFolder zimbraMailTrashLifetime
        zimbraMailSpamLifetime zimbraMailMessageLifetime zimbraContactMaxNumEntries zimbraAuthTokenLifetime
        zimbraAdminAuthTokenLifetime zimbraMailMinPollingInterval zimbraPrefMailPollingInterval zimbraAttachmentsBlocked
        zimbraAttachmentsViewInHtmlOnly zimbraPrefForwardReplyPrefixChar zimbraPrefAutoAddAddressEnabled
        zimbraPrefReplyIncludeOriginalText zimbraPrefForwardIncludeOriginalText zimbraFeatureContactsEnabled
        zimbraFeatureCalendarEnabled zimbraFeatureTaggingEnabled zimbraFeatureSavedSearchesEnabled
        zimbraFeatureConversationsEnabled zimbraFeatureChangePasswordEnabled zimbraFeatureInitialSearchPreferenceEnabled
        zimbraFeatureFiltersEnabled zimbraPrefDedupeMessagesSentToSelf zimbraPrefMessageViewHtmlPreferred
        zimbraMailIdleSessionTimeout zimbraPrefContactsPerPage zimbraFeatureGalEnabled zimbraNewMailNotificationFrom
        zimbraNewMailNotificationSubject zimbraNewMailNotificationBody zimbraPrefMailSignatureStyle
        zimbraAttachmentsIndexingEnabled zimbraImapEnabled zimbraPop3Enabled zimbraPrefShowFragments
        zimbraPrefComposeInNewWindow zimbraPrefComposeFormat zimbraPrefForwardReplyInOriginalFormat
        zimbraFeatureHtmlComposeEnabled zimbraPrefShowSearchString zimbraPrefTimeZoneId
        zimbraPrefUseTimeZoneListInCalendar zimbraPrefCalendarInitialView zimbraPrefImapSearchFoldersEnabled
        zimbraPrefHtmlEditorDefaultFontFamily zimbraPrefHtmlEditorDefaultFontSize zimbraPrefHtmlEditorDefaultFontColor
        zimbraPrefCalendarFirstDayOfWeek zimbraPrefCalendarNotifyDelegatedChanges zimbraPrefCalendarUseQuickAdd
        zimbraPrefCalendarAlwaysShowMiniCal zimbraZimletAvailableZimlets zimbraProxyAllowedDomains
        zimbraFeatureViewInHtmlEnabled zimbraFeatureSharingEnabled zimbraPrefCalendarApptReminderWarningTime
        zimbraFeatureMailForwardingEnabled zimbraLocale zimbraFeatureMobileSyncEnabled zimbraFeatureSkinChangeEnabled
        zimbraPrefSkin zimbraFeatureGalAutoCompleteEnabled zimbraAvailableSkin zimbraFeatureOutOfOfficeReplyEnabled
        zimbraFeatureNewMailNotificationEnabled zimbraPrefGalAutoCompleteEnabled zimbraPasswordLockoutEnabled
        zimbraPasswordLockoutDuration zimbraPasswordLockoutMaxFailures zimbraPasswordLockoutFailureLifetime
        zimbraPrefOutOfOfficeCacheDuration zimbraPasswordMinUpperCaseChars zimbraPasswordMinLowerCaseChars
        zimbraPasswordMinPunctuationChars zimbraPasswordMinNumericChars zimbraTextAnalyzer zimbraPrefUseRfc2231
        zimbraPrefShortcuts zimbraDomainAdminMaxMailQuota zimbraPrefForwardReplyFormat zimbraIdentityMaxNumEntries
        zimbraFeatureIdentitiesEnabled zimbraFeaturePop3DataSourceEnabled zimbraDataSourceMaxNumEntries
        zimbraAllowAnyFromAddress zimbraArchiveAccountNameTemplate zimbraArchiveAccountDateTemplate
        zimbraFeatureTasksEnabled zimbraSyncWindowSize zimbraPrefCalendarDayHourStart zimbraPrefCalendarDayHourEnd
        zimbraPrefLocale zimbraFeatureVoiceEnabled zimbraAdminSavedSearches zimbraFeaturePortalEnabled zimbraPortalName
        zimbraFeatureOptionsEnabled zimbraPrefClientType zimbraMailSignatureMaxLength zimbraDataSourcePollingInterval
        zimbraPrefWarnOnExit zimbraPrefMailDefaultCharset zimbraPrefDeleteInviteOnReply zimbraPrefShowSelectionCheckbox
        zimbraFeatureGroupCalendarEnabled zimbraNotebookMaxRevisions zimbraQuotaWarnPercent zimbraQuotaWarnInterval
        zimbraQuotaWarnMessage zimbraAvailableLocale zimbraFeatureMailEnabled zimbraSignatureMaxNumEntries
        zimbraFeatureSignaturesEnabled zimbraFeatureBriefcasesEnabled zimbraFeatureFlaggingEnabled
        zimbraPrefOpenMailInNewWindow zimbraPrefDisplayExternalImages zimbraFeatureInstantNotify
        zimbraSignatureMinNumEntries zimbraDataSourceMinPollingInterval zimbraPrefVoiceItemsPerPage
        zimbraFeatureMailUpsellEnabled zimbraFeatureMailUpsellURL zimbraFeatureContactsUpsellEnabled
        zimbraFeatureContactsUpsellURL zimbraFeatureCalendarUpsellEnabled zimbraFeatureCalendarUpsellURL
        zimbraFeatureVoiceUpsellEnabled zimbraFeatureVoiceUpsellURL zimbraPrefInboxUnreadLifetime
        zimbraPrefInboxReadLifetime zimbraPrefSentLifetime zimbraPrefJunkLifetime zimbraPrefTrashLifetime
        zimbraFeatureZimbraAssistantEnabled zimbraPrefAutoSaveDraftInterval zimbraFeatureMailPriorityEnabled
        zimbraFeatureImapDataSourceEnabled zimbraJunkMessagesIndexingEnabled zimbraFeatureComposeInNewWindowEnabled
        zimbraFeatureOpenMailInNewWindowEnabled zimbraSpamApplyUserFilters zimbraFreebusyExchangeURL
        zimbraFreebusyExchangeAuthUsername zimbraFreebusyExchangeAuthPassword zimbraFreebusyExchangeUserOrg
        zimbraFreebusyExchangeAuthScheme zimbraInterceptAddress zimbraInterceptSendHeadersOnly zimbraInterceptFrom
        zimbraInterceptSubject zimbraInterceptBody zimbraBatchedIndexingSize zimbraFreebusyExchangeCachedIntervalStart
        zimbraFreebusyExchangeCachedInterval zimbraFeatureNewAddrBookEnabled zimbraPrefTagTreeOpen
        zimbraPrefSearchTreeOpen zimbraPrefGalSearchEnabled zimbraPrefFolderTreeOpen zimbraPrefZimletTreeOpen
        zimbraNotebookSanitizeHtml zimbraPrefMarkMsgRead zimbraPrefPop3DownloadSince zimbraACE
        zimbraPrefMailSoundsEnabled zimbraPrefCalendarReminderSoundsEnabled zimbraPrefAdvancedClientEnforceMinDisplay
        zimbraPrefMailFlashTitle zimbraPrefMailFlashIcon zimbraPrefCalendarReminderFlashTitle
        zimbraPrefCalendarAllowForwardedInvite zimbraPrefCalendarAllowPublishMethodInvite
        zimbraPrefStandardClientAccessibilityMode zimbraPrefListViewColumns zimbraPrefCalendarAllowCancelEmailToSelf
        zimbraFeatureMailForwardingInFiltersEnabled zimbraCalendarMaxRevisions zimbraFeatureGalSyncEnabled
        zimbraMailPurgeUseChangeDateForTrash zimbraPrefMandatorySpellCheckEnabled zimbraFreebusyLocalMailboxNotActive
        zimbraContactRankingTableSize zimbraPrefSharedAddrBookAutoCompleteEnabled zimbraPrefZimlets
        zimbraDataSourcePop3PollingInterval zimbraDataSourceImapPollingInterval zimbraDataSourceLivePollingInterval
        zimbraDataSourceRssPollingInterval zimbraPrefFolderColorEnabled zimbraFeatureDiscardInFiltersEnabled
        zimbraDataSourceCaldavPollingInterval zimbraDataSourceYabPollingInterval zimbraSmtpEnableTrace
        zimbraMailWhitelistMaxNumEntries zimbraMailBlacklistMaxNumEntries zimbraPrefReadingPaneLocation
        zimbraFeatureConfirmationPageEnabled zimbraPrefMailToasterEnabled zimbraPrefCalendarToasterEnabled
        zimbraPrefIMToasterEnabled zimbraCalendarCalDavSyncStart zimbraCalendarCalDavSyncEnd
        zimbraCalendarCalDavSharedFolderCacheDuration zimbraPrefConversationOrder
        zimbraDataSourceCalendarPollingInterval zimbraFeatureReadReceiptsEnabled zimbraPrefMailSendReadReceipts
        zimbraDataSourceGalPollingInterval zimbraContactAutoCompleteMaxResults zimbraPrefCalendarApptVisibility
        zimbraFeatureMobilePolicyEnabled zimbraMobilePolicyAllowNonProvisionableDevices
        zimbraMobilePolicyAllowPartialProvisioning zimbraMobilePolicyRefreshInterval
        zimbraMobilePolicyDevicePasswordEnabled zimbraMobilePolicyMinDevicePasswordLength
        zimbraMobilePolicyAllowSimpleDevicePassword zimbraMobilePolicyAlphanumericDevicePasswordRequired
        zimbraMobilePolicyMinDevicePasswordComplexCharacters zimbraMobilePolicyDevicePasswordExpiration
        zimbraMobilePolicyDevicePasswordHistory zimbraMobilePolicyMaxInactivityTimeDeviceLock
        zimbraMobilePolicyMaxDevicePasswordFailedAttempts zimbraMobilePolicyPasswordRecoveryEnabled
        zimbraPrefCalendarAutoAddInvites zimbraPrefCalendarSendInviteDeniedAutoReply zimbraPrefConvReadingPaneLocation
        zimbraMaxMailItemsPerPage zimbraMaxContactsPerPage zimbraMaxVoiceItemsPerPage
        zimbraPrefCalendarShowPastDueReminders zimbraGalSyncAccountBasedAutoCompleteEnabled
        zimbraPrefAppleIcalDelegationEnabled zimbraPrefAdminConsoleWarnOnExit zimbraMailForwardingAddressMaxLength
        zimbraMailForwardingAddressMaxNumAddrs zimbraPrefSpellDictionary zimbraPrefShowCalendarWeek
        zimbraPrefMailSelectAfterDelete zimbraWebClientShowOfflineLink zimbraPrefAccountTreeOpen
        zimbraFeatureVoiceChangePinEnabled zimbraFeatureManageZimlets zimbraFeatureBriefcaseSpreadsheetEnabled
        zimbraFeatureBriefcaseSlidesEnabled zimbraFeatureBriefcaseDocsEnabled zimbraPrefGetMailAction
        zimbraPrefMailFoldersCheckedForNewMsgIndicator zimbraPrefSpellIgnoreWord zimbraPrefDisabledZimlets
        zimbraSmtpRestrictEnvelopeFrom zimbraPrefItemsPerVirtualPage zimbraCalendarResourceDoubleBookingAllowed
        zimbraContactEmailFields zimbraPrefCalendarApptAllowAtendeeEdit zimbraPrefAutoCompleteQuickCompletionOnComma
        zimbraCalendarShowResourceTabs zimbraPrefDefaultPrintFontSize zimbraMailAllowReceiveButNotSendWhenOverQuota
        zimbraPrefCalendarWorkingHours zimbraMailPurgeUseChangeDateForSpam zimbraFeatureMAPIConnectorEnabled
        zimbraDumpsterEnabled zimbraMailDumpsterLifetime zimbraFeatureDistributionListExpandMembersEnabled
        zimbraFeatureMailSendLaterEnabled zimbraPrefMailTrustedSenderList zimbraMailTrustedSenderListMaxNumEntries
        zimbraFeatureFreeBusyViewEnabled zimbraFeatureCalendarReminderDeviceEmailEnabled
        zimbraPrefTasksReadingPaneLocation zimbraPrefBriefcaseReadingPaneLocation zimbraFilterBatchSize
        zimbraFilterSleepInterval zimbraMailThreadingAlgorithm zimbraPasswordMinAlphaChars zimbraPasswordAllowedChars
        zimbraFeatureContactsDetailedSearchEnabled zimbraPrefPop3DeleteOption zimbraPrefPop3IncludeSpam
        zimbraFeatureAntispamEnabled zimbraFeatureAdminMailEnabled zimbraPrefShortEmailAddress
        zimbraFeatureManageSMIMECertificateEnabled zimbraFeatureImportFolderEnabled zimbraFeatureExportFolderEnabled
        zimbraFeatureSMIMEEnabled zimbraPrefCalendarDefaultApptDuration zimbraPrefSortOrder
        zimbraPrefCalendarViewTimeInterval zimbraPrefCalendarShowDeclinedMeetings zimbraPrefFileSharingApplication
        zimbraPrefMessageIdDedupingEnabled zimbraMobileSmartForwardRFC822Enabled zimbraArchiveEnabled
        zimbraPrefSpellIgnoreAllCaps zimbraDefaultFolderFlags zimbraMailHighlightObjectsMaxSize
        zimbraPrefMailRequestReadReceipts zimbraCalendarLocationDisabledFields
        zimbraCalendarKeepExceptionsOnSeriesTimeChange zimbraPrefOutOfOfficeStatusAlertOnLogin zimbraPrefFont
        zimbraPasswordMinDigitsOrPuncs zimbraPasswordAllowedPunctuationChars zimbraExternalShareLifetime
        zimbraExternalSharingEnabled zimbraExternalShareWhitelistDomain zimbraExternalShareDomainWhitelistEnabled
        zimbraStandardClientCustomPrefTabsEnabled zimbraStandardClientCustomPrefTab zimbraFeaturePriorityInboxEnabled
        zimbraFeatureSocialFiltersEnabled zimbraPrefComposeDirection zimbraPrefShowComposeDirection
        zimbraMobilePolicyAllowStorageCard zimbraMobilePolicyAllowCamera zimbraMobilePolicyRequireDeviceEncryption
        zimbraMobilePolicyAllowUnsignedApplications zimbraMobilePolicyAllowUnsignedInstallationPackages
        zimbraMobilePolicyAllowWiFi zimbraMobilePolicyAllowTextMessaging zimbraMobilePolicyAllowPOPIMAPEmail
        zimbraMobilePolicyAllowBluetooth zimbraMobilePolicyAllowIrDA zimbraMobilePolicyRequireManualSyncWhenRoaming
        zimbraMobilePolicyAllowDesktopSync zimbraMobilePolicyMaxCalendarAgeFilter zimbraMobilePolicyAllowHTMLEmail
        zimbraMobilePolicyMaxEmailAgeFilter zimbraMobilePolicyMaxEmailBodyTruncationSize
        zimbraMobilePolicyMaxEmailHTMLBodyTruncationSize zimbraMobilePolicyRequireSignedSMIMEMessages
        zimbraMobilePolicyRequireEncryptedSMIMEMessages zimbraMobilePolicyRequireSignedSMIMEAlgorithm
        zimbraMobilePolicyRequireEncryptionSMIMEAlgorithm zimbraMobilePolicyAllowSMIMEEncryptionAlgorithmNegotiation
        zimbraMobilePolicyAllowSMIMESoftCerts zimbraMobilePolicyAllowBrowser zimbraMobilePolicyAllowConsumerEmail
        zimbraMobilePolicyAllowRemoteDesktop zimbraMobilePolicyAllowInternetSharing
        zimbraMobilePolicyUnapprovedInROMApplication zimbraMobilePolicyApprovedApplication
        zimbraMobilePolicySuppressDeviceEncryption zimbraFileExpirationWarningThreshold zimbraFileLifetime
        zimbraFileExpirationWarningSubject zimbraFileExpirationWarningBody zimbraFileDeletionNotificationSubject
        zimbraFileDeletionNotificationBody zimbraDumpsterUserVisibleAge zimbraDumpsterPurgeEnabled
        zimbraInternalSendersDomain zimbraPrefExternalSendersType zimbraPrefTasksFilterBy zimbraFileVersioningEnabled
        zimbraFileVersionLifetime zimbraPrefIncludeSharedItemsInSearch zimbraShareLifetime
        zimbraFileUploadMaxSizePerFile zimbraPublicSharingEnabled zimbraPublicShareLifetime zimbraFileShareLifetime
        zimbraFileExternalShareLifetime zimbraFilePublicShareLifetime zimbraExternalAccountLifetimeAfterDisabled
        zimbraFeatureExternalFeedbackEnabled zimbraFeatureCrocodocEnabled zimbraFileAndroidCrashReportingEnabled
        zimbraFeatureSocialcastEnabled zimbraSocialcastURL zimbraFileIOSCrashReportingEnabled
        zimbraZimletLoadSynchronously zimbraPrefConvShowCalendar zimbraDevicePasscodeEnabled
        zimbraDeviceAllowedPasscodeLockoutDuration zimbraDevicePasscodeLockoutDuration zimbraDeviceLockWhenInactive
        zimbraDeviceFileOpenWithEnabled zimbraUCServiceId zimbraMobilePolicyApprovedApplicationList
        zimbraDeviceOfflineCacheEnabled zimbraDataSourceImportOnLogin zimbraMobileNotificationEnabled
        zimbraMobileNotificationAdminAddress zimbraMobileAttachSkippedItemEnabled zimbraPrefColorMessagesEnabled
        zimbraMobileMetadataMaxSizeEnabled zimbraMobileItemsToTrackPerFolderMaxSize zimbraPrefSpellIgnorePattern
        zimbraTouchJSErrorTrackingEnabled zimbraTouchJSErrorTrackingKey zimbraForceClearCookies
        zimbraFeatureDistributionListFolderEnabled zimbraMobileSyncKeyFormatConvertedFolders zimbraConverterHints
        zimbraFilePreviewMaxSize zimbraMobilePolicyRequireStorageCardEncryption zimbraPrefFontSize
        zimbraDeviceCalendarSoftDeleteExcludePattern zimbraWebClientOfflineSyncMaxDays zimbraMobileOutlookSyncEnabled
        zimbraFeatureFromDisplayEnabled zimbraFeatureSocialEnabled zimbraFeatureSocialExternalEnabled
        zimbraFeatureSocialExternalURL zimbraMobileShareContactEnabled zimbraMobileForceSamsungProtocol25
        zimbraMobileForceProtocol25 zimbraFeatureEwsEnabled zimbraFeatureWebClientOfflineAccessEnabled
        zimbraFeatureSocialName zimbraPrefCalendarAllowedTargetsForInviteDeniedAutoReply zimbraMobileTombstoneEnabled
        zimbraLogOutFromAllServers zimbraFeatureTouchClientEnabled zimbraCommunityAPIClientID
        zimbraCommunityAPIClientSecret zimbraCommunityUsernameMapping zimbraCommunityBaseURL zimbraCommunityHomeURL
        zimbraMobileSyncRedoMaxAttempts zimbraPrefUseSendMsgShortcut zimbraPrefDelegatedSendSaveTarget
        zimbraFeatureAdminPreferencesEnabled zimbraPrefShowChatsFolderInMail zimbraFeatureTwoFactorAuthRequired
        zimbraTwoFactorAuthNumScratchCodes zimbraMaxAppSpecificPasswords
        zimbraRevokeAppSpecificPasswordsOnPasswordChange zimbraAppSpecificPasswordDuration
        zimbraPrefShowAllNewMailNotifications zimbraFeatureAppSpecificPasswordsEnabled
        zimbraTwoFactorAuthTrustedDeviceTokenLifetime zimbraPrefZmgPushNotificationEnabled zimbraPrefTabInEditorEnabled
        zimbraFeatureDataSourcePurgingEnabled zimbraDataSourceQuota zimbraDataSourceTotalQuota
        zimbraNewMailNotificationMessage zimbraTwoFactorAuthTokenLifetime zimbraTwoFactorAuthEnablementTokenLifetime
        zimbraZimletUserPropertiesMaxNumEntries zimbraDisableCrossAccountConversationThreading
        zimbraFeatureTwoFactorAuthAvailable zimbraPrefChatPlaySound zimbraFeatureChatEnabled
        zimbraFeatureTrustedDevicesEnabled zimbraMobileSearchMimeSupportEnabled zimbraExportMaxDays
        zimbraPrefChatEnabled zimbraTwoFactorAuthLockoutMaxFailures zimbraFeatureMobileGatewayEnabled
        zimbraPasswordLockoutSuppressionCacheSize zimbraPasswordLockoutSuppressionEnabled
        zimbraPasswordLockoutSuppressionProtocols zimbraChatHistoryEnabled zimbraSieveRejectMailEnabled
        zimbraSieveNotifyActionRFCCompliant zimbraAdminSieveScriptBefore zimbraAdminSieveScriptAfter
        zimbraAdminOutgoingSieveScriptBefore zimbraAdminOutgoingSieveScriptAfter zimbraSieveRequireControlEnabled
        zimbraSieveEditHeaderEnabled zimbraSieveImmutableHeaders zimbraFeatureMarkMailForwardedAsRead
        zimbraFeatureAddressVerificationEnabled zimbraFeatureAddressVerificationExpiry zimbraFeatureContactBackupEnabled
        zimbraPrefOutOfOfficeSpecificDomains zimbraPrefDisplayTimeInMailList zimbraMailHostPool
        zimbraFeatureAdvancedSearchEnabled zimbraFeatureResetPasswordStatus zimbraFeatureResetPasswordSuspensionTime
        zimbraPasswordRecoveryMaxAttempts zimbraPrefDefaultCalendarId zimbraRecoveryAccountCodeValidity
        zimbraResetPasswordRecoveryCodeExpiry zimbraShowClientTOS
      ]

      zimbra_attr %i[zimbraId zimbraCreateTimestamp], readonly: true

      def modify!(force: false)
        return false unless force || zimbra_attrs_changed?

        sac.invoke(build_modify(force:))
        clear_zimbra_attrs_changes
        true
      end

      def build_modify(force: false)
        jsns_builder.to_update(force:)
      end

      def update!(hash = nil, update_attributes: true, force: false, **attrs)
        hash = hash.nil? ? attrs : hash.merge(attrs)
        return false if zimbra_attrs_to_update(hash, force).empty?

        do_update!(hash)

        do_update_attributes(hash) if update_attributes

        @updated = true
      end

      def do_update_attributes(hash)
        hash.each do |key, value|
          update_attribute(key, value)
          forget_zimbra_attr_change(key)
        end
      end

      def create!
        resp = sac.invoke(build_create)

        clear_zimbra_attrs_changes
        @id = resp[:CreateCosResponse][:cos].first[:id]
      end

      def build_create
        jsns_builder.to_create
      end

      def delete!
        sac.invoke(build_delete)
      end

      def build_delete
        jsns_builder.to_delete
      end

      def clone!(new_name)
        resp = sac.invoke(build_clone(new_name))
        resp[:CopyCosResponse][:cos].first[:id]
      end

      def build_clone(new_name)
        jsns_builder.to_copy(new_name)
      end

      has_many :servers, klass: :'Zm::Client::CosServersCollection'
      has_many :domains, klass: :'Zm::Client::CosDomainsCollection'
      has_many :accounts, klass: :'Zm::Client::CosAccountsCollection'

      private

      def do_update!(hash)
        sac.invoke(jsns_builder.to_patch(hash))
      end
    end
  end
end
