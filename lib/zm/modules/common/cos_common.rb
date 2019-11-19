module CosCommon

  ZM_COS_ATTRS = %w[
    zimbraPrefCalendarReminderMobile
    zimbraPrefIMLogChats
    zimbraDeviceLockWhenInactive
    zimbraPrefFileSharingApplication
    zimbraDataSourceTotalQuota
    zimbraPrefCalendarWorkingHours
    zimbraFeatureOutOfOfficeReplyEnabled
    zimbraPrefCalendarViewTimeInterval
    zimbraPrefComposeFormat
    zimbraPrefZmgPushNotificationEnabled
    zimbraPrefDisplayTimeInMailList
    zimbraPrefIMNotifyStatus
    zimbraQuotaWarnPercent
    zimbraPrefIMReportIdle
    zimbraFeatureMailForwardingEnabled
    zimbraPrefDisplayExternalImages
    zimbraPrefSaveToSent
    zimbraPrefOutOfOfficeCacheDuration
    zimbraPrefConvReadingPaneLocation
    zimbraPrefShowSearchString
    zimbraInterceptSubject
    zimbraMailTrustedSenderListMaxNumEntries
    zimbraPrefMailSelectAfterDelete
    zimbraPrefAppleIcalDelegationEnabled
    zimbraDataSourceQuota
    zimbraPrefHtmlEditorDefaultFontFamily
    zimbraMobilePolicyMinDevicePasswordComplexCharacters
    zimbraPrefConvShowCalendar
    zimbraRevokeAppSpecificPasswordsOnPasswordChange
    zimbraZimletUserPropertiesMaxNumEntries
    zimbraFeatureSMIMEEnabled
    zimbraPrefCalendarShowPastDueReminders
    zimbraMobilePolicyAllowPOPIMAPEmail
    zimbraDataSourceMinPollingInterval
    zimbraMobilePolicyRequireSignedSMIMEMessages
    zimbraPrefWarnOnExit
    zimbraFeatureMobileGatewayEnabled
    cn
    zimbraFeaturePriorityInboxEnabled
    zimbraPrefReadingPaneEnabled
    zimbraFeatureBriefcaseSpreadsheetEnabled
    zimbraSpamApplyUserFilters
    zimbraFeatureAddressVerificationExpiry
    zimbraMobilePolicyMaxEmailBodyTruncationSize
    zimbraQuotaWarnInterval
    zimbraPrefIMToasterEnabled
    zimbraPrefOutOfOfficeStatusAlertOnLogin
    zimbraFeatureMailPriorityEnabled
    zimbraPrefAutocompleteAddressBubblesEnabled
    zimbraFeatureManageZimlets
    zimbraPasswordMinNumericChars
    zimbraWebClientShowOfflineLink
    zimbraMobileSmartForwardRFC822Enabled
    zimbraPrefContactsInitialView
    zimbraFeatureCalendarEnabled
    zimbraMailBlacklistMaxNumEntries
    zimbraPrefVoiceItemsPerPage
    zimbraMobilePolicyAllowRemoteDesktop
    zimbraFeatureDiscardInFiltersEnabled
    zimbraFeatureTrustedDevicesEnabled
    zimbraMobilePolicyPasswordRecoveryEnabled
    zimbraMailHighlightObjectsMaxSize
    zimbraPrefMailToasterEnabled
    zimbraFileAndroidCrashReportingEnabled
    zimbraPrefForwardReplyInOriginalFormat
    zimbraFeatureWebSearchEnabled
    zimbraPrefBriefcaseReadingPaneLocation
    zimbraPrefContactsPerPage
    zimbraPrefMarkMsgRead
    zimbraPrefMessageIdDedupingEnabled
    zimbraPrefCalendarApptReminderWarningTime
    zimbraPrefCalendarReminderYMessenger
    zimbraSieveRejectMailEnabled
    zimbraPrefCalendarDefaultApptDuration
    zimbraPrefDeleteInviteOnReply
    zimbraPrefCalendarDayHourStart
    zimbraMaxVoiceItemsPerPage
    zimbraPrefPop3DeleteOption
    zimbraDataSourceMaxNumEntries
    zimbraImapEnabled
    zimbraFeatureViewInHtmlEnabled
    zimbraCalendarMaxRevisions
    zimbraPrefTabInEditorEnabled
    zimbraMailSignatureMaxLength
    zimbraPrefCalendarAutoAddInvites
    zimbraPasswordLockoutSuppressionCacheSize
    zimbraFeatureSignaturesEnabled
    zimbraPrefExternalSendersType
    zimbraPrefContactsDisableAutocompleteOnContactGroupMembers
    zimbraPrefIMFlashTitle
    zimbraLogOutFromAllServers
    zimbraPasswordLockoutMaxFailures
    zimbraMobilePolicyDevicePasswordHistory
    zimbraMobilePolicyAllowDesktopSync
    zimbraMobileTombstoneEnabled
    zimbraFeatureImapDataSourceEnabled
    zimbraPrefSentLifetime
    zimbraFeatureSocialEnabled
    zimbraMobilePolicyAllowUnsignedInstallationPackages
    zimbraContactRankingTableSize
    zimbraPrefAutoCompleteQuickCompletionOnComma
    zimbraPrefMailFlashIcon
    zimbraPrefMailSoundsEnabled
    zimbraAuthTokenLifetime
    zimbraNewMailNotificationFrom
    zimbraPrefFolderColorEnabled
    zimbraFeatureMailSendLaterEnabled
    zimbraPortalName
    zimbraSieveRequireControlEnabled
    zimbraTwoFactorAuthEnablementTokenLifetime
    zimbraMobileSearchMimeSupportEnabled
    zimbraMailThreadingAlgorithm
    zimbraMobilePolicyAllowNonProvisionableDevices
    zimbraFeatureContactBackupEnabled
    zimbraPrefIMSoundsEnabled
    zimbraPrefGalAutoCompleteEnabled
    zimbraPrefIMHideBlockedBuddies
    zimbraPrefUseSendMsgShortcut
    zimbraMobileOutlookSyncEnabled
    zimbraPrefCalendarReminderSoundsEnabled
    zimbraPrefCalendarShowDeclinedMeetings
    zimbraFeatureEwsEnabled
    zimbraDeviceAllowedPasscodeLockoutDuration
    zimbraFeatureComposeInNewWindowEnabled
    zimbraFeatureContactsEnabled
    zimbraPrefIMInstantNotify
    zimbraPasswordMaxAge
    zimbraFeatureContactsDetailedSearchEnabled
    zimbraFeatureFlaggingEnabled
    zimbraPrefMailInitialSearch
    zimbraPrefIMNotifyPresence
    zimbraPrefMandatorySpellCheckEnabled
    zimbraFeatureSocialFiltersEnabled
    zimbraPrefDedupeMessagesSentToSelf
    zimbraPrefHtmlEditorDefaultFontSize
    zimbraExternalShareDomainWhitelistEnabled
    zimbraMobilePolicyAllowSMIMEEncryptionAlgorithmNegotiation
    zimbraInterceptBody
    zimbraIdentityMaxNumEntries
    zimbraFeatureAdminMailEnabled
    zimbraBatchedIndexingSize
    zimbraDataSourceImportOnLogin
    zimbraFeatureMAPIConnectorEnabled
    zimbraFeatureTwoFactorAuthRequired
    zimbraMobilePolicyRequireSignedSMIMEAlgorithm
    zimbraCalendarResourceDoubleBookingAllowed
    zimbraPrefSentMailFolder
    zimbraFileIOSCrashReportingEnabled
    zimbraPrefCalendarApptVisibility
    zimbraPrefCalendarDayHourEnd
    zimbraFeatureConversationsEnabled
    zimbraFeatureDistributionListExpandMembersEnabled
    zimbraPasswordLockoutFailureLifetime
    zimbraPrefShowComposeDirection
    zimbraPrefShowCalendarWeek
    zimbraFeatureImportExportFolderEnabled
    zimbraMobilePolicyRequireDeviceEncryption
    zimbraMobilePolicyDeviceEncryptionEnabled
    zimbraFileShareLifetime
    zimbraMobileNotificationEnabled
    zimbraMobilePolicyMaxCalendarAgeFilter
    zimbraPasswordMinLowerCaseChars
    zimbraPrefClientType
    zimbraPrefIMAutoLogin
    zimbraFeaturePeopleSearchEnabled
    zimbraNotebookMaxRevisions
    zimbraPrefCalendarAlwaysShowMiniCal
    zimbraPrefChatPlaySound
    zimbraFeatureExternalFeedbackEnabled
    zimbraProxyAllowedDomains
    zimbraPrefHtmlEditorDefaultFontColor
    zimbraMaxAppSpecificPasswords
    zimbraFeatureBriefcaseDocsEnabled
    zimbraFilterSleepInterval
    zimbraFeatureReadReceiptsEnabled
    zimbraExternalSharingEnabled
    zimbraPasswordLockoutSuppressionEnabled
    zimbraPrefTasksReadingPaneLocation
    zimbraPrefItemsPerVirtualPage
    zimbraSyncWindowSize
    zimbraDisableCrossAccountConversationThreading
    zimbraChatHistoryEnabled
    zimbraFeatureAntispamEnabled
    zimbraPrefSearchTreeOpen
    zimbraPrefStandardClientAccessibilityMode
    zimbraPrefUseRfc2231
    zimbraPrefCalendarNotifyDelegatedChanges
    zimbraFeatureChangePasswordEnabled
    zimbraPrefShowChatsFolderInMail
    zimbraMobilePolicyMaxDevicePasswordFailedAttempts
    zimbraDeviceFileOpenWithEnabled
    zimbraPrefConversationOrder
    zimbraFeatureMarkMailForwardedAsRead
    zimbraMobilePolicyAllowSimpleDevicePassword
    zimbraDataSourceRssPollingInterval
    zimbraPrefIncludeSharedItemsInSearch
    zimbraAttachmentsIndexingEnabled
    zimbraDumpsterPurgeEnabled
    zimbraPasswordLockoutEnabled
    zimbraArchiveAccountNameTemplate
    zimbraStandardClientCustomPrefTabsEnabled
    zimbraTwoFactorAuthTrustedDeviceTokenLifetime
    zimbraFeatureVoiceEnabled
    zimbraPrefShowSelectionCheckbox
    zimbraPrefDelegatedSendSaveTarget
    zimbraPrefPop3IncludeSpam
    zimbraFeatureBriefcaseSlidesEnabled
    zimbraMobileAttachSkippedItemEnabled
    zimbraPrefCalendarReminderFlashTitle
    zimbraFeatureMailForwardingInFiltersEnabled
    zimbraPrefDefaultPrintFontSize
    zimbraFeatureSocialcastEnabled
    zimbraPrefMailFlashTitle
    zimbraPrefMessageViewHtmlPreferred
    zimbraFeatureCalendarUpsellEnabled
    zimbraMobilePolicyAllowSMIMESoftCerts
    zimbraMobilePolicyMaxEmailAgeFilter
    zimbraInterceptSendHeadersOnly
    zimbraMobileForceSamsungProtocol25
    zimbraPrefMailPollingInterval
    zimbraPrefFontSize
    zimbraId
    zimbraPrefIMLogChatsEnabled
    zimbraPrefReplyIncludeOriginalText
    zimbraFeatureGalSyncEnabled
    zimbraFeatureIdentitiesEnabled
    zimbraPrefIncludeTrashInSearch
    zimbraPrefSharedAddrBookAutoCompleteEnabled
    zimbraFeatureImportFolderEnabled
    zimbraFeatureOptionsEnabled
    zimbraFeatureAdvancedSearchEnabled
    zimbraPrefCalendarAllowCancelEmailToSelf
    zimbraFeatureChatEnabled
    zimbraFeatureTasksEnabled
    zimbraExternalAccountLifetimeAfterDisabled
    zimbraMailPurgeUseChangeDateForTrash
    zimbraDevicePasscodeEnabled
    zimbraPrefCalendarAllowPublishMethodInvite
    zimbraSieveImmutableHeaders
    zimbraPasswordLocked
    zimbraFeatureNewAddrBookEnabled
    zimbraMobilePolicyRequireEncryptedSMIMEMessages
    zimbraMobilePolicyRefreshInterval
    zimbraFeatureAddressVerificationEnabled
    zimbraFeatureVoiceChangePinEnabled
    zimbraCalendarCalDavSharedFolderCacheDuration
    zimbraPasswordMinAlphaChars
    zimbraPrefIMIdleStatus
    zimbraMailSpamLifetime
    zimbraPrefSpellIgnoreWord
    zimbraPrefGroupMailBy
    zimbraMailHostPool
    zimbraMailForwardingAddressMaxNumAddrs
    zimbraNewMailNotificationSubject
    zimbraMailQuota
    zimbraQuotaWarnMessage
    zimbraContactAutoCompleteEmailFields
    zimbraFeatureZimbraAssistantEnabled
    zimbraPrefCalendarAllowForwardedInvite
    zimbraFeatureGroupCalendarEnabled
    zimbraFilterBatchSize
    zimbraPrefZimletTreeOpen
    zimbraArchiveAccountDateTemplate
    zimbraSignatureMaxNumEntries
    zimbraPrefCalendarUseQuickAdd
    zimbraPrefComposeInNewWindow
    zimbraAttachmentsBlocked
    zimbraPrefGalSearchEnabled
    zimbraPrefJunkLifetime
    zimbraPrefSpellIgnoreAllCaps
    zimbraFeatureManageSMIMECertificateEnabled
    zimbraMailDumpsterLifetime
    zimbraAppSpecificPasswordDuration
    zimbraCalendarKeepExceptionsOnSeriesTimeChange
    zimbraPrefUseTimeZoneListInCalendar
    zimbraPrefCalendarAllowedTargetsForInviteDeniedAutoReply
    zimbraExportMaxDays
    zimbraMobilePolicyAlphanumericDevicePasswordRequired
    zimbraPrefOpenMailInNewWindow
    zimbraAdminAuthTokenLifetime
    zimbraFileExternalShareLifetime
    zimbraFeatureTaggingEnabled
    zimbraCalendarShowResourceTabs
    zimbraMobilePolicyRequireStorageCardEncryption
    zimbraPrefMailSignatureStyle
    zimbraTwoFactorAuthLockoutMaxFailures
    zimbraArchiveEnabled
    zimbraDeviceOfflineCacheEnabled
    zimbraMailIdleSessionTimeout
    zimbraPop3Enabled
    zimbraMailAllowReceiveButNotSendWhenOverQuota
    zimbraDataSourceCalendarPollingInterval
    zimbraPrefAdminConsoleWarnOnExit
    zimbraPrefTrashLifetime
    zimbraMailMinPollingInterval
    zimbraPrefShowFragments
    zimbraMobilePolicyDevicePasswordExpiration
    zimbraFeatureSocialExternalEnabled
    zimbraFeatureAdminPreferencesEnabled
    zimbraFeaturePop3DataSourceEnabled
    zimbraGalSyncAccountBasedAutoCompleteEnabled
    zimbraMobilePolicyAllowBrowser
    zimbraJunkMessagesIndexingEnabled
    zimbraPrefContactsExpandAppleContactGroups
    zimbraPasswordMinUpperCaseChars
    zimbraPrefIMFlashIcon
    zimbraMobileForceProtocol25
    zimbraPrefMailRequestReadReceipts
    zimbraPrefCalendarReminderDuration1
    zimbraPrefAdvancedClientEnforceMinDisplay
    zimbraPublicSharingEnabled
    zimbraMobilePolicyAllowStorageCard
    zimbraZimletLoadSynchronously
    zimbraPrefCalendarFirstDayOfWeek
    description
    zimbraFeatureIMEnabled
    zimbraContactAutoCompleteMaxResults
    zimbraMobilePolicyAllowCamera
    zimbraPasswordMinDigitsOrPuncs
    zimbraFilePublicShareLifetime
    zimbraPasswordMinPunctuationChars
    zimbraPrefSkin
    zimbraPrefForwardReplyPrefixChar
    zimbraExternalShareLifetime
    zimbraMobilePolicyRequireEncryptionSMIMEAlgorithm
    zimbraFeatureWebClientOfflineAccessEnabled
    zimbraPrefShowAllNewMailNotifications
    zimbraNotebookSanitizeHtml
    zimbraPasswordMinAge
    zimbraMaxMailItemsPerPage
    zimbraSignatureMinNumEntries
    zimbraMobilePolicyAllowInternetSharing
    zimbraPrefAccountTreeOpen
    zimbraFeatureSharingEnabled
    zimbraPrefAutoSaveDraftInterval
    zimbraMobilePolicyAllowIrDA
    zimbraNewMailNotificationBody
    zimbraMobilePolicyRequireManualSyncWhenRoaming
    zimbraFeatureMailUpsellEnabled
    zimbraFeatureSavedSearchesEnabled
    zimbraPrefForwardReplyFormat
    zimbraPrefCalendarToasterEnabled
    zimbraMobilePolicyAllowConsumerEmail
    zimbraFeatureFreeBusyViewEnabled
    zimbraPasswordMaxLength
    zimbraZimletAvailableZimlets
    zimbraPasswordEnforceHistory
    zimbraFeatureTouchClientEnabled
    zimbraDumpsterEnabled
    zimbraAttachmentsViewInHtmlOnly
    zimbraSieveNotifyActionRFCCompliant
    objectClass
    zimbraPrefColorMessagesEnabled
    zimbraPrefCalendarApptAllowAtendeeEdit
    zimbraMaxContactsPerPage
    zimbraFeatureCrocodocEnabled
    zimbraFeatureBriefcasesEnabled
    zimbraFeatureContactsUpsellEnabled
    zimbraPrefIncludeSpamInSearch
    zimbraFeatureVoiceUpsellEnabled
    zimbraPrefCalendarInitialView
    zimbraPrefFolderTreeOpen
    zimbraPrefInboxUnreadLifetime
    zimbraFeatureInstantNotify
    zimbraMobilePolicyAllowBluetooth
    zimbraMobilePolicyDevicePasswordEnabled
    zimbraPrefImapSearchFoldersEnabled
    zimbraFeatureAppSpecificPasswordsEnabled
    zimbraFeatureMailPollingIntervalPreferenceEnabled
    zimbraFeatureDistributionListFolderEnabled
    zimbraPrefMailSendReadReceipts
    zimbraShareLifetime
    zimbraInterceptFrom
    zimbraMobilePolicyAllowWiFi
    zimbraMailWhitelistMaxNumEntries
    zimbraMobilePolicyAllowTextMessaging
    zimbraPrefForwardIncludeOriginalText
    zimbraMobilePolicyAllowPartialProvisioning
    zimbraPrefMailItemsPerPage
    zimbraPrefUseKeyboardShortcuts
    zimbraPublicShareLifetime
    zimbraMobilePolicyMinDevicePasswordLength
    zimbraTwoFactorAuthNumScratchCodes
    zimbraFeatureConfirmationPageEnabled
    zimbraFileUploadMaxSizePerFile
    zimbraMobilePolicySuppressDeviceEncryption
    zimbraWebClientOfflineSyncMaxDays
    zimbraPasswordLockoutDuration
    zimbraPrefTimeZoneId
    zimbraSieveEditHeaderEnabled
    zimbraFeatureNewMailNotificationEnabled
    zimbraProxyCacheableContentTypes
    zimbraPasswordMinLength
    zimbraPrefShortEmailAddress
    zimbraFeatureOpenMailInNewWindowEnabled
    zimbraPrefIMHideOfflineBuddies
    zimbraMobilePolicyAllowUnsignedApplications
    zimbraMobilePolicyMaxInactivityTimeDeviceLock
    zimbraFeatureGalEnabled
    zimbraFilePreviewMaxSize
    zimbraMailPurgeUseChangeDateForSpam
    zimbraContactMaxNumEntries
    zimbraMailMessageLifetime
    zimbraAllowAnyFromAddress
    zimbraFreebusyLocalMailboxNotActive
    zimbraPrefChatEnabled
    zimbraSmtpRestrictEnvelopeFrom
    zimbraPasswordLockoutSuppressionProtocols
    zimbraIMService
    zimbraPrefInboxReadLifetime
    zimbraPrefTagTreeOpen
    zimbraMobileShareContactEnabled
    zimbraFeatureGalAutoCompleteEnabled
    zimbraPrefGetMailAction
    zimbraMobilePolicyAllowHTMLEmail
    zimbraTouchJSErrorTrackingEnabled
    zimbraFeatureNotebookEnabled
    zimbraPrefAutoAddAddressEnabled
    zimbraFeatureTwoFactorAuthAvailable
    zimbraFeatureSkinChangeEnabled
    zimbraFeatureMobilePolicyEnabled
    zimbraMobilePolicyMaxEmailHTMLBodyTruncationSize
    zimbraPrefReadingPaneLocation
    zimbraMailForwardingAddressMaxLength
    zimbraFeatureMailEnabled
    zimbraFeatureDataSourcePurgingEnabled
    zimbraContactEmailFields
    zimbraFeaturePortalEnabled
    zimbraPrefCalendarReminderSendEmail
    zimbraFeatureCalendarReminderDeviceEmailEnabled
    zimbraFeatureShortcutAliasesEnabled
    zimbraPrefCalendarSendInviteDeniedAutoReply
    zimbraDumpsterUserVisibleAge
    zimbraFeatureHtmlComposeEnabled
    zimbraFeatureFiltersEnabled
    zimbraFeatureFromDisplayEnabled
    zimbraPrefIMIdleTimeout
    zimbraFeatureInitialSearchPreferenceEnabled
    zimbraFeatureMobileSyncEnabled
    zimbraTwoFactorAuthTokenLifetime
    zimbraFeatureExportFolderEnabled
    zimbraMailTrashLifetime
    zimbraMobileSyncRedoMaxAttempts
  ].freeze

  ALL_ATTRS = ZM_COS_ATTRS
  ATTRS_READ = ZM_COS_ATTRS
  ATTRS_WRITE = ZM_COS_ATTRS

  ATTRS_READ.each { |attr| attr_reader attr }
  ATTRS_WRITE.each { |attr| attr_accessor attr }

  def attrs_read
    ATTRS_READ
  end

  def attrs_write
    ATTRS_WRITE
  end
end