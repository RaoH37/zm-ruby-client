# frozen_string_literal: true

module Zm
  module Client
    # objectClass: zimbraAccount
    class Account < Base::MailboxObject
      include SoapRequest::RequestMethodsAdmin
      extend Base::HasZimbraAttributes

      zimbra_attr %i[
        c co company cn description destinationIndicator displayName facsimileTelephoneNumber gn givenName homePhone
        initials internationaliSDNNumber l mobile o ou pager physicalDeliveryOfficeName postOfficeBox postalAddress
        postalCode preferredDeliveryMethod registeredAddress sn st street streetAddress telephoneNumber
        teletexTerminalIdentifier telexNumber title userCertificate userPassword userSMIMECertificate x121Address
        zimbraAccountStatus zimbraMailHost zimbraNotes zimbraMailForwardingAddress zimbraCOSId zimbraMailStatus
        zimbraMailQuota zimbraPrefMailSignature zimbraPrefMailSignatureEnabled zimbraPrefSaveToSent zimbraIsAdminAccount
        zimbraMailSieveScript zimbraPasswordMinLength zimbraPasswordMaxLength zimbraPasswordMinAge zimbraPasswordMaxAge
        zimbraPasswordEnforceHistory zimbraPasswordHistory zimbraPasswordModifiedTime zimbraPasswordMustChange
        zimbraPasswordLocked zimbraPrefGroupMailBy zimbraPrefIncludeSpamInSearch zimbraPrefIncludeTrashInSearch
        zimbraPrefMailItemsPerPage zimbraPrefOutOfOfficeReply zimbraPrefOutOfOfficeReplyEnabled zimbraPrefReplyToAddress
        zimbraPrefUseKeyboardShortcuts zimbraPrefMailInitialSearch zimbraPrefSentMailFolder zimbraMailTrashLifetime
        zimbraMailSpamLifetime zimbraMailMessageLifetime zimbraContactMaxNumEntries zimbraAuthTokenLifetime
        zimbraAdminAuthTokenLifetime zimbraMailMinPollingInterval zimbraPrefMailPollingInterval zimbraAttachmentsBlocked
        zimbraAttachmentsViewInHtmlOnly zimbraPrefNewMailNotificationEnabled zimbraPrefNewMailNotificationAddress
        zimbraPrefForwardReplyPrefixChar zimbraPrefAutoAddAddressEnabled zimbraPrefReplyIncludeOriginalText
        zimbraPrefForwardIncludeOriginalText zimbraFeatureContactsEnabled zimbraFeatureCalendarEnabled
        zimbraFeatureTaggingEnabled zimbraFeatureSavedSearchesEnabled zimbraFeatureConversationsEnabled
        zimbraFeatureChangePasswordEnabled zimbraFeatureInitialSearchPreferenceEnabled zimbraFeatureFiltersEnabled
        zimbraPrefDedupeMessagesSentToSelf zimbraPrefMessageViewHtmlPreferred zimbraMailIdleSessionTimeout
        zimbraPrefContactsPerPage zimbraFeatureGalEnabled zimbraNewMailNotificationFrom zimbraNewMailNotificationSubject
        zimbraNewMailNotificationBody zimbraPrefMailSignatureStyle zimbraAttachmentsIndexingEnabled zimbraImapEnabled
        zimbraPop3Enabled zimbraPrefShowFragments zimbraPrefComposeInNewWindow zimbraMailCanonicalAddress
        zimbraMailCatchAllAddress zimbraMailCatchAllForwardingAddress zimbraMailCatchAllCanonicalAddress
        zimbraPrefComposeFormat zimbraPrefForwardReplyInOriginalFormat zimbraFeatureHtmlComposeEnabled
        zimbraPrefShowSearchString zimbraPrefTimeZoneId zimbraPrefUseTimeZoneListInCalendar
        zimbraPrefCalendarInitialView zimbraPrefImapSearchFoldersEnabled zimbraMailTransport zimbraAuthLdapExternalDn
        zimbraPrefHtmlEditorDefaultFontFamily zimbraPrefHtmlEditorDefaultFontSize zimbraPrefHtmlEditorDefaultFontColor
        zimbraPrefCalendarFirstDayOfWeek zimbraPrefCalendarNotifyDelegatedChanges zimbraPrefCalendarUseQuickAdd
        zimbraPrefCalendarInitialCheckedCalendars zimbraPrefCalendarAlwaysShowMiniCal zimbraZimletAvailableZimlets
        zimbraProxyAllowedDomains zimbraForeignPrincipal zimbraZimletUserProperties zimbraIsDomainAdminAccount
        zimbraFeatureViewInHtmlEnabled zimbraAccountCalendarUserType zimbraFeatureSharingEnabled
        zimbraPrefCalendarApptReminderWarningTime zimbraFeatureMailForwardingEnabled zimbraPrefMailForwardingAddress
        zimbraPrefMailLocalDeliveryDisabled zimbraLocale zimbraMailboxLocationBeforeMove zimbraFeatureMobileSyncEnabled
        zimbraHideInGal zimbraFeatureSkinChangeEnabled zimbraPrefSkin zimbraFeatureGalAutoCompleteEnabled
        zimbraAvailableSkin zimbraDebugInfo zimbraFeatureOutOfOfficeReplyEnabled zimbraFeatureNewMailNotificationEnabled
        zimbraPrefGalAutoCompleteEnabled zimbraIsSystemResource zimbraPasswordLockoutEnabled
        zimbraPasswordLockoutDuration zimbraPasswordLockoutMaxFailures zimbraPasswordLockoutFailureLifetime
        zimbraPasswordLockoutLockedTime zimbraPasswordLockoutFailureTime zimbraPrefOutOfOfficeFromDate
        zimbraPrefOutOfOfficeUntilDate zimbraPrefOutOfOfficeCacheDuration zimbraPrefOutOfOfficeDirectAddress
        zimbraPasswordMinUpperCaseChars zimbraPasswordMinLowerCaseChars zimbraPasswordMinPunctuationChars
        zimbraPasswordMinNumericChars zimbraTextAnalyzer zimbraPrefUseRfc2231 zimbraPrefShortcuts
        zimbraDomainAdminMaxMailQuota zimbraVersion zimbraPrefFromDisplay zimbraPrefFromAddress zimbraPrefReplyToDisplay
        zimbraPrefReplyToEnabled zimbraPrefWhenSentToEnabled zimbraPrefWhenSentToAddresses
        zimbraPrefWhenInFoldersEnabled zimbraPrefWhenInFolderIds zimbraPrefBccAddress zimbraPrefIdentityName
        zimbraPrefForwardReplyFormat zimbraIdentityMaxNumEntries zimbraFeatureIdentitiesEnabled
        zimbraFeaturePop3DataSourceEnabled zimbraDataSourceMaxNumEntries zimbraAllowAnyFromAddress
        zimbraAllowFromAddress zimbraArchiveAccount zimbraArchiveAccountNameTemplate zimbraArchiveAccountDateTemplate
        zimbraFeatureTasksEnabled zimbraSyncWindowSize zimbraPrefCalendarDayHourStart zimbraPrefCalendarDayHourEnd
        zimbraPrefLocale zimbraFeatureVoiceEnabled zimbraAdminSavedSearches zimbraFeaturePortalEnabled zimbraPortalName
        zimbraFeatureOptionsEnabled zimbraPrefClientType zimbraMailSignatureMaxLength zimbraDataSourcePollingInterval
        zimbraPrefWarnOnExit zimbraPrefMailDefaultCharset zimbraPrefDeleteInviteOnReply zimbraPrefShowSelectionCheckbox
        zimbraFeatureGroupCalendarEnabled zimbraNotebookMaxRevisions zimbraQuotaWarnPercent zimbraQuotaLastWarnTime
        zimbraQuotaWarnInterval zimbraQuotaWarnMessage zimbraAvailableLocale zimbraFeatureMailEnabled zimbraSignatureId
        zimbraSignatureName zimbraPrefDefaultSignatureId zimbraSignatureMaxNumEntries zimbraFeatureSignaturesEnabled
        zimbraFeatureBriefcasesEnabled zimbraFeatureFlaggingEnabled zimbraPrefOpenMailInNewWindow
        zimbraExcludeFromCMBSearch zimbraPrefDisplayExternalImages zimbraPrefMailSignatureHTML
        zimbraFeatureInstantNotify zimbraSignatureMinNumEntries zimbraDataSourceMinPollingInterval
        zimbraPrefVoiceItemsPerPage zimbraFeatureMailUpsellEnabled zimbraFeatureMailUpsellURL
        zimbraFeatureContactsUpsellEnabled zimbraFeatureContactsUpsellURL zimbraFeatureCalendarUpsellEnabled
        zimbraFeatureCalendarUpsellURL zimbraFeatureVoiceUpsellEnabled zimbraFeatureVoiceUpsellURL
        zimbraPrefInboxUnreadLifetime zimbraPrefInboxReadLifetime zimbraPrefSentLifetime zimbraPrefJunkLifetime
        zimbraPrefTrashLifetime zimbraFeatureZimbraAssistantEnabled zimbraPrefAutoSaveDraftInterval
        zimbraFeatureMailPriorityEnabled zimbraFeatureImapDataSourceEnabled zimbraPrefCalendarReminderEmail
        zimbraJunkMessagesIndexingEnabled zimbraFeatureComposeInNewWindowEnabled zimbraFeatureOpenMailInNewWindowEnabled
        zimbraIsCustomerCareAccount zimbraPrefLabel zimbraSpamApplyUserFilters zimbraCustomerCareTier
        zimbraFreebusyExchangeURL zimbraFreebusyExchangeAuthUsername zimbraFreebusyExchangeAuthPassword
        zimbraFreebusyExchangeUserOrg zimbraFreebusyExchangeAuthScheme zimbraInterceptAddress
        zimbraInterceptSendHeadersOnly zimbraInterceptFrom zimbraInterceptSubject zimbraInterceptBody
        zimbraBatchedIndexingSize zimbraFreebusyExchangeCachedIntervalStart zimbraFreebusyExchangeCachedInterval
        zimbraFeatureNewAddrBookEnabled zimbraPrefTagTreeOpen zimbraPrefSearchTreeOpen zimbraPrefGalSearchEnabled
        zimbraPrefFolderTreeOpen zimbraPrefZimletTreeOpen zimbraNotebookSanitizeHtml zimbraPrefMarkMsgRead
        zimbraPrefPop3DownloadSince zimbraYahooId zimbraACE zimbraPrefMailSoundsEnabled
        zimbraPrefCalendarReminderSoundsEnabled zimbraPrefAdvancedClientEnforceMinDisplay zimbraPrefMailFlashTitle
        zimbraPrefMailFlashIcon zimbraPrefCalendarReminderFlashTitle zimbraPrefCalendarAllowForwardedInvite
        zimbraPrefCalendarAllowPublishMethodInvite zimbraPrefStandardClientAccessibilityMode zimbraPrefListViewColumns
        zimbraPrefCalendarAllowCancelEmailToSelf zimbraFeatureMailForwardingInFiltersEnabled zimbraCalendarMaxRevisions
        zimbraFeatureGalSyncEnabled zimbraMailPurgeUseChangeDateForTrash zimbraPrefMandatorySpellCheckEnabled
        zimbraFreebusyLocalMailboxNotActive zimbraContactRankingTableSize zimbraPrefSharedAddrBookAutoCompleteEnabled
        zimbraAdminConsoleUIComponents zimbraPrefZimlets zimbraDataSourcePop3PollingInterval
        zimbraDataSourceImapPollingInterval zimbraDataSourceLivePollingInterval zimbraDataSourceRssPollingInterval
        zimbraPrefFolderColorEnabled zimbraFeatureDiscardInFiltersEnabled zimbraReverseProxyUseExternalRoute
        zimbraExternalPop3Port zimbraExternalPop3SSLPort zimbraExternalImapPort zimbraExternalImapSSLPort
        zimbraExternalPop3Hostname zimbraExternalPop3SSLHostname zimbraExternalImapHostname
        zimbraExternalImapSSLHostname zimbraDataSourceCaldavPollingInterval zimbraDataSourceYabPollingInterval
        zimbraSmtpEnableTrace zimbraMailWhitelistMaxNumEntries zimbraMailBlacklistMaxNumEntries
        zimbraPrefReadingPaneLocation zimbraFeatureConfirmationPageEnabled zimbraPrefMailToasterEnabled
        zimbraPrefCalendarToasterEnabled zimbraPrefIMToasterEnabled zimbraCalendarCalDavSyncStart
        zimbraCalendarCalDavSyncEnd zimbraCalendarCalDavSharedFolderCacheDuration zimbraPrefConversationOrder
        zimbraDataSourceCalendarPollingInterval zimbraFeatureReadReceiptsEnabled zimbraPrefMailSendReadReceipts
        zimbraDataSourceGalPollingInterval zimbraContactAutoCompleteMaxResults zimbraPrefCalendarApptVisibility
        zimbraFeatureMobilePolicyEnabled zimbraMobilePolicyAllowNonProvisionableDevices
        zimbraMobilePolicyAllowPartialProvisioning zimbraMobilePolicyRefreshInterval
        zimbraMobilePolicyDevicePasswordEnabled zimbraMobilePolicyMinDevicePasswordLength
        zimbraMobilePolicyAllowSimpleDevicePassword zimbraMobilePolicyAlphanumericDevicePasswordRequired
        zimbraMobilePolicyMinDevicePasswordComplexCharacters zimbraMobilePolicyDevicePasswordExpiration
        zimbraMobilePolicyDevicePasswordHistory zimbraMobilePolicyMaxInactivityTimeDeviceLock
        zimbraMobilePolicyMaxDevicePasswordFailedAttempts zimbraMobilePolicyPasswordRecoveryEnabled
        zimbraPrefCalendarAutoAddInvites zimbraPrefCalendarSendInviteDeniedAutoReply zimbraPrefCalendarForwardInvitesTo
        zimbraIsDelegatedAdminAccount zimbraPrefConvReadingPaneLocation zimbraMaxMailItemsPerPage
        zimbraMaxContactsPerPage zimbraMaxVoiceItemsPerPage zimbraPrefCalendarShowPastDueReminders
        zimbraGalSyncAccountBasedAutoCompleteEnabled zimbraPrefAppleIcalDelegationEnabled
        zimbraPrefAdminConsoleWarnOnExit zimbraMailForwardingAddressMaxLength zimbraMailForwardingAddressMaxNumAddrs
        zimbraPrefSpellDictionary zimbraAuthTokenValidityValue zimbraPrefShowCalendarWeek
        zimbraPrefMailSelectAfterDelete zimbraWebClientShowOfflineLink zimbraPrefAccountTreeOpen
        zimbraFeatureVoiceChangePinEnabled zimbraFeatureManageZimlets zimbraFeatureBriefcaseSpreadsheetEnabled
        zimbraFeatureBriefcaseSlidesEnabled zimbraFeatureBriefcaseDocsEnabled zimbraPrefGetMailAction
        zimbraPrefMailFoldersCheckedForNewMsgIndicator zimbraPrefSpellIgnoreWord zimbraPrefDisabledZimlets
        zimbraSmtpRestrictEnvelopeFrom zimbraPrefItemsPerVirtualPage zimbraCalendarResourceDoubleBookingAllowed
        zimbraContactEmailFields zimbraPrefCalendarApptAllowAtendeeEdit zimbraPrefAutoCompleteQuickCompletionOnComma
        zimbraCalendarShowResourceTabs zimbraPrefDefaultPrintFontSize zimbraMailAllowReceiveButNotSendWhenOverQuota
        zimbraPrefCalendarWorkingHours zimbraMailPurgeUseChangeDateForSpam zimbraPrefForwardReplySignatureId
        zimbraFeatureMAPIConnectorEnabled zimbraDumpsterEnabled zimbraPrefMailSignatureContactId
        zimbraMailOutgoingSieveScript zimbraMailDumpsterLifetime zimbraFeatureDistributionListExpandMembersEnabled
        zimbraFeatureMailSendLaterEnabled zimbraPrefMailTrustedSenderList zimbraMailTrustedSenderListMaxNumEntries
        zimbraCalendarReminderDeviceEmail zimbraFeatureFreeBusyViewEnabled zimbraPhoneticFirstName
        zimbraPhoneticLastName zimbraPhoneticCompany zimbraFeatureCalendarReminderDeviceEmailEnabled
        zimbraPrefTasksReadingPaneLocation zimbraPrefBriefcaseReadingPaneLocation zimbraFilterBatchSize
        zimbraFilterSleepInterval zimbraMailThreadingAlgorithm zimbraPasswordMinAlphaChars zimbraPasswordAllowedChars
        zimbraFeatureContactsDetailedSearchEnabled zimbraPrefPop3DeleteOption zimbraPrefPop3IncludeSpam
        zimbraFeatureAntispamEnabled zimbraFeatureAdminMailEnabled zimbraPrefShortEmailAddress
        zimbraFeatureManageSMIMECertificateEnabled zimbraFeatureImportFolderEnabled zimbraFeatureExportFolderEnabled
        zimbraFeatureSMIMEEnabled zimbraPrefCalendarDefaultApptDuration zimbraPrefSortOrder
        zimbraPrefCalendarAutoAcceptSignatureId zimbraPrefCalendarAutoDeclineSignatureId
        zimbraPrefCalendarAutoDenySignatureId zimbraPrefCalendarViewTimeInterval zimbraPrefCalendarShowDeclinedMeetings
        zimbraPrefFileSharingApplication zimbraPrefMessageIdDedupingEnabled zimbraPrefCalendarAcceptSignatureId
        zimbraPrefCalendarTentativeSignatureId zimbraPrefCalendarDeclineSignatureId
        zimbraMobileSmartForwardRFC822Enabled zimbraArchiveEnabled zimbraPrefSpellIgnoreAllCaps zimbraDefaultFolderFlags
        zimbraPrefQuickCommand zimbraMailHighlightObjectsMaxSize zimbraIsSystemAccount zimbraPrefMailRequestReadReceipts
        zimbraCalendarLocationDisabledFields zimbraSharedItem zimbraCalendarKeepExceptionsOnSeriesTimeChange
        zimbraIsExternalVirtualAccount zimbraExternalUserMailAddress zimbraPrefOutOfOfficeStatusAlertOnLogin
        zimbraPrefFont zimbraPasswordMinDigitsOrPuncs zimbraPasswordAllowedPunctuationChars zimbraExternalShareLifetime
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
        zimbraMobilePolicySuppressDeviceEncryption zimbraPrefCalendarReminderDeviceInfo
        zimbraFileExpirationWarningThreshold zimbraFileLifetime zimbraFileExpirationWarningSubject
        zimbraFileExpirationWarningBody zimbraFileDeletionNotificationSubject zimbraFileDeletionNotificationBody
        zimbraDumpsterUserVisibleAge zimbraDumpsterPurgeEnabled zimbraPrefOutOfOfficeExternalReply
        zimbraPrefOutOfOfficeExternalReplyEnabled zimbraInternalSendersDomain zimbraPrefExternalSendersType
        zimbraPrefTasksFilterBy zimbraFileVersioningEnabled zimbraFileVersionLifetime
        zimbraPrefAllowAddressForDelegatedSender zimbraPrefOutOfOfficeFreeBusyStatus
        zimbraPrefIncludeSharedItemsInSearch zimbraShareLifetime zimbraFileUploadMaxSizePerFile
        zimbraPublicSharingEnabled zimbraPublicShareLifetime zimbraFileShareLifetime zimbraFileExternalShareLifetime
        zimbraFilePublicShareLifetime zimbraExternalAccountDisabledTime zimbraExternalAccountLifetimeAfterDisabled
        zimbraFeatureExternalFeedbackEnabled zimbraFeatureCrocodocEnabled zimbraFileAndroidCrashReportingEnabled
        zimbraFeatureSocialcastEnabled zimbraSocialcastURL zimbraFileIOSCrashReportingEnabled
        zimbraZimletLoadSynchronously zimbraPrefConvShowCalendar zimbraDevicePasscodeEnabled
        zimbraDeviceAllowedPasscodeLockoutDuration zimbraDevicePasscodeLockoutDuration zimbraDeviceLockWhenInactive
        zimbraDeviceFileOpenWithEnabled zimbraUCServiceId zimbraUCUsername zimbraUCPassword
        zimbraMobilePolicyApprovedApplicationList zimbraDeviceOfflineCacheEnabled zimbraVirtualAccountInitialPasswordSet
        zimbraDataSourceImportOnLogin zimbraPrefFromAddressType zimbraMobileNotificationEnabled
        zimbraMobileNotificationAdminAddress zimbraMobileAttachSkippedItemEnabled zimbraPrefColorMessagesEnabled
        zimbraMobileMetadataMaxSizeEnabled zimbraMobileItemsToTrackPerFolderMaxSize zimbraPrefSpellIgnorePattern
        zimbraTouchJSErrorTrackingEnabled zimbraTouchJSErrorTrackingKey zimbraForceClearCookies
        zimbraFeatureDistributionListFolderEnabled zimbraMobileSyncKeyFormatConvertedFolders zimbraConverterHints
        zimbraFilePreviewMaxSize zimbraMobilePolicyRequireStorageCardEncryption zimbraPrefFontSize
        zimbraDeviceCalendarSoftDeleteExcludePattern zimbraWebClientOfflineSyncMaxDays zimbraMobileOutlookSyncEnabled
        zimbraFeatureFromDisplayEnabled zimbraFeatureSocialEnabled zimbraFeatureSocialExternalEnabled
        zimbraFeatureSocialExternalURL zimbraMobileShareContactEnabled zimbraPrefWebClientOfflineBrowserKey
        zimbraMobileForceSamsungProtocol25 zimbraMobileForceProtocol25 zimbraFeatureEwsEnabled
        zimbraPrefOutOfOfficeSuppressExternalReply zimbraAuthTokens zimbraFeatureWebClientOfflineAccessEnabled
        zimbraFeatureSocialName zimbraPrefCalendarAllowedTargetsForInviteDeniedAutoReply zimbraMobileTombstoneEnabled
        zimbraLogOutFromAllServers zimbraFeatureTouchClientEnabled zimbraCommunityAPIClientID
        zimbraCommunityAPIClientSecret zimbraCommunityUsernameMapping zimbraCommunityBaseURL zimbraCommunityHomeURL
        zimbraMobileSyncRedoMaxAttempts zimbraCommunityID zimbraPrefUseSendMsgShortcut zimbraPrefDelegatedSendSaveTarget
        zimbraFeatureAdminPreferencesEnabled zimbraIsMobileGatewayAppAccount zimbraPrefShowChatsFolderInMail
        zimbraTwoFactorAuthEnabled zimbraFeatureTwoFactorAuthRequired zimbraTwoFactorAuthNumScratchCodes
        zimbraMaxAppSpecificPasswords zimbraRevokeAppSpecificPasswordsOnPasswordChange zimbraAppSpecificPasswordDuration
        zimbraPrefShowAllNewMailNotifications zimbraFeatureAppSpecificPasswordsEnabled
        zimbraTwoFactorAuthTrustedDeviceTokenLifetime zimbraPrefZmgPushNotificationEnabled zimbraPrefTabInEditorEnabled
        zimbraFeatureDataSourcePurgingEnabled zimbraDataSourceQuota zimbraDataSourceTotalQuota
        zimbraNewMailNotificationMessage zimbraTwoFactorAuthTokenLifetime zimbraTwoFactorAuthEnablementTokenLifetime
        zimbraZimletUserPropertiesMaxNumEntries zimbraIsMobileGatewayProxyAccount
        zimbraDisableCrossAccountConversationThreading zimbraOAuthAccessor zimbraFeatureTwoFactorAuthAvailable
        zimbraPrefChatPlaySound zimbraFeatureChatEnabled zimbraFeatureTrustedDevicesEnabled
        zimbraMobileSearchMimeSupportEnabled zimbraExportMaxDays zimbraPrefChatEnabled
        zimbraTwoFactorAuthLockoutMaxFailures zimbraTwoFactorAuthLockoutFailureTime zimbraFeatureMobileGatewayEnabled
        zimbraAvailabilityServiceProvider zimbraPasswordLockoutSuppressionCacheSize
        zimbraPasswordLockoutSuppressionEnabled zimbraPasswordLockoutSuppressionProtocols zimbraChatHistoryEnabled
        zimbraSieveRejectMailEnabled zimbraSieveNotifyActionRFCCompliant zimbraAdminSieveScriptBefore
        zimbraAdminSieveScriptAfter zimbraAdminOutgoingSieveScriptBefore zimbraAdminOutgoingSieveScriptAfter
        zimbraSieveRequireControlEnabled zimbraSieveEditHeaderEnabled zimbraSieveImmutableHeaders
        zimbraFeatureMarkMailForwardedAsRead zimbraFeatureAddressVerificationEnabled
        zimbraFeatureAddressVerificationExpiry zimbraFeatureAddressUnderVerification
        zimbraFeatureAddressVerificationStatus zimbraFeatureContactBackupEnabled zimbraPrefOutOfOfficeSpecificDomains
        thumbnailPhoto zimbraPrefDisplayTimeInMailList zimbraFeatureAdvancedSearchEnabled
        zimbraFeatureResetPasswordStatus zimbraFeatureResetPasswordSuspensionTime zimbraPasswordRecoveryMaxAttempts
        zimbraPrefDefaultCalendarId zimbraRecoveryAccountCodeValidity zimbraResetPasswordRecoveryCodeExpiry
        zimbraShowClientTOS
      ]

      zimbra_attr %i[
        mail uid zimbraId zimbraMailAddress zimbraMemberOf zimbraMailDeliveryAddress zimbraMailAlias
        zimbraLastLogonTimestamp zimbraCreateTimestamp zimbraTwoFactorAuthSecret zimbraTwoFactorAuthScratchCodes
        zimbraAppSpecificPassword zimbraTwoFactorAuthTrustedDevices
      ], readonly: true

      # #################################################################
      # Associations
      # #################################################################

      def cos
        return @cos if defined? @cos

        @cos = @parent.coses.find_by(id: zimbraCOSId)
      end

      # #################################################################
      # SOAP Actions
      # #################################################################

      def create!
        resp = sac.invoke(build_create)
        clear_zimbra_attrs_changes
        @id = resp[:CreateAccountResponse][:account].first[:id]
      end

      def created_at
        return @created_at if defined? @created_at

        @created_at = Time.parse(zimbraCreateTimestamp) unless zimbraCreateTimestamp.nil?
      end

      def flush_cache!
        sac.invoke(build_flush_cache)
        true
      end

      def build_flush_cache
        soap_request = Zm::SoapRequest::SoapElement.admin(Zm::SoapRequest::SoapAdminConstants::FLUSH_CACHE_REQUEST)
        node_cache = Zm::SoapRequest::SoapElement.create('cache')
                                .add_attributes({ type: Zm::SoapRequest::SoapConstants::ACCOUNT, allServers: Zm::Utils::SearchUtils::ON })
        soap_request.add_node(node_cache)
        node_entry = Zm::SoapRequest::SoapElement.create('entry')
                                .add_attribute(Zm::SoapRequest::SoapConstants::BY, SoapRequest::SoapConstants::ID)
                                .add_content(@id)
        node_cache.add_node(node_entry)
        soap_request
      end

      has_jsns_builder

      def batch
        return @batch if defined? @batch

        @batch = BatchRequest.new(soap_account_connector)
      end

      def empty_dumpster!
        soap_request = Zm::SoapRequest::SoapElement.mail(SoapRequest::SoapMailConstants::EMPTY_DUMPSTER_REQUEST)
        soap_connector.invoke(soap_request)
      end

      private

      def do_update!(hash)
        sac.invoke(jsns_builder.to_patch(hash))
      end
    end
  end
end
