# frozen_string_literal: true

require 'zm/client/backup'
require 'zm/client/mta_queue'

module Zm
  module Client
    # objectClass: zimbraServer
    class Server < Base::AdminObject

      INSTANCE_VARIABLE_KEYS = %i[
        zimbraActiveSyncEhcacheExpiration
        zimbraActiveSyncEhcacheHeapSize
        zimbraActiveSyncEhcacheMaxDiskSize
        zimbraAdminImapImportNumThreads
        zimbraAdminPort
        zimbraAdminProxyPort
        zimbraAdminSieveFeatureVariablesEnabled
        zimbraAdminURL
        zimbraAmavisDSPAMEnabled
        zimbraAmavisEnableDKIMVerification
        zimbraAmavisFinalSpamDestiny
        zimbraAmavisLogLevel
        zimbraAmavisMaxServers
        zimbraAmavisOriginatingBypassSA
        zimbraAmavisSALogLevel
        zimbraAntispamExtractionBatchDelay
        zimbraAntispamExtractionBatchSize
        zimbraAttachmentsIndexedTextLimit
        zimbraAuthTokenNotificationInterval
        zimbraAutoProvPollingInterval
        zimbraBackupAutoGroupedInterval
        zimbraBackupAutoGroupedNumGroups
        zimbraBackupAutoGroupedThrottled
        zimbraBackupMinFreeSpace
        zimbraBackupMode
        zimbraBackupReportEmailRecipients
        zimbraBackupReportEmailSender
        zimbraBackupReportEmailSubjectPrefix
        zimbraBackupSkipBlobs
        zimbraBackupSkipHsmBlobs
        zimbraBackupSkipSearchIndex
        zimbraBackupTarget
        zimbraCBPolicydAccessControlEnabled
        zimbraCBPolicydAccountingEnabled
        zimbraCBPolicydAmavisEnabled
        zimbraCBPolicydBindPort
        zimbraCBPolicydBypassMode
        zimbraCBPolicydBypassTimeout
        zimbraCBPolicydCheckHeloEnabled
        zimbraCBPolicydCheckSPFEnabled
        zimbraCBPolicydGreylistingBlacklistMsg
        zimbraCBPolicydGreylistingDeferMsg
        zimbraCBPolicydGreylistingEnabled
        zimbraCBPolicydGreylistingTrainingEnabled
        zimbraCBPolicydLogLevel
        zimbraCBPolicydMaxRequests
        zimbraCBPolicydMaxServers
        zimbraCBPolicydMaxSpareServers
        zimbraCBPolicydMinServers
        zimbraCBPolicydMinSpareServers
        zimbraCBPolicydQuotasEnabled
        zimbraCBPolicydTimeoutBusy
        zimbraCBPolicydTimeoutIdle
        zimbraCalendarCalDavClearTextPasswordEnabled
        zimbraCalendarCalDavDefaultCalendarId
        zimbraCalendarRecurrenceDailyMaxDays
        zimbraCalendarRecurrenceMaxInstances
        zimbraCalendarRecurrenceMonthlyMaxMonths
        zimbraCalendarRecurrenceOtherFrequencyMaxYears
        zimbraCalendarRecurrenceWeeklyMaxWeeks
        zimbraCalendarRecurrenceYearlyMaxYears
        zimbraChatAllowUnencryptedPassword
        zimbraChatServiceEnabled
        zimbraChatXmppPort
        zimbraChatXmppSslPort
        zimbraChatXmppSslPortEnabled
        zimbraClamAVBindAddress
        zimbraClamAVDatabaseMirror
        zimbraClamAVListenPort
        zimbraClamAVMaxThreads
        zimbraClamAVSafeBrowsing
        zimbraClusterType
        zimbraConfiguredServerIDForBlobDirEnabled
        zimbraContactHiddenAttributes
        zimbraContactRankingTableRefreshInterval
        zimbraContactSearchDecomposition
        zimbraConvertPoolTimeout
        zimbraConvertdURL
        zimbraCreateTimestamp
        zimbraDNSTCPUpstream
        zimbraDNSUseTCP
        zimbraDNSUseUDP
        zimbraDatabaseSlowSqlThreshold
        zimbraEmptyFolderOpTimeout
        zimbraExtensionBindPort
        zimbraExternalAccountStatusCheckInterval
        zimbraFeatureContactBackupFrequency
        zimbraFeatureContactBackupLifeTime
        zimbraFileUploadMaxSize
        zimbraFreebusyPropagationRetryInterval
        zimbraHsmAge
        zimbraHsmBatchSize
        zimbraHsmMovePreviousRevisions
        zimbraHsmPolicy
        zimbraHttpCompressionEnabled
        zimbraHttpConnectorMaxIdleTimeMillis
        zimbraHttpContextPathBasedThreadPoolBalancingFilterRules
        zimbraHttpDebugHandlerEnabled
        zimbraHttpDosFilterDelayMillis
        zimbraHttpDosFilterMaxRequestsPerSec
        zimbraHttpHeaderCacheSize
        zimbraHttpMaxFormContentSize
        zimbraHttpNumThreads
        zimbraHttpOutputBufferSize
        zimbraHttpRequestHeaderSize
        zimbraHttpResponseHeaderSize
        zimbraHttpSSLNumThreads
        zimbraHttpThreadPoolMaxIdleTimeMillis
        zimbraHttpThrottleSafeIPs
        zimbraIPMode
        zimbraId
        zimbraImapActiveSessionEhcacheMaxDiskSize
        zimbraImapBindOnStartup
        zimbraImapBindPort
        zimbraImapCleartextLoginEnabled
        zimbraImapDisplayMailFoldersOnly
        zimbraImapExposeVersionOnBanner
        zimbraImapInactiveSessionCacheMaxDiskSize
        zimbraImapInactiveSessionEhcacheMaxDiskSize
        zimbraImapInactiveSessionEhcacheSize
        zimbraImapLoadBalancingAlgorithm
        zimbraImapMaxConnections
        zimbraImapMaxRequestSize
        zimbraImapNumThreads
        zimbraImapProxyBindPort
        zimbraImapSSLBindOnStartup
        zimbraImapSSLBindPort
        zimbraImapSSLProxyBindPort
        zimbraImapSSLServerEnabled
        zimbraImapSaslGssapiEnabled
        zimbraImapServerEnabled
        zimbraImapShutdownGraceSeconds
        zimbraInvalidLoginFilterDelayInMinBetwnReqBeforeReinstating
        zimbraInvalidLoginFilterMaxFailedLogin
        zimbraInvalidLoginFilterMaxSizeOfFailedIpDb
        zimbraInvalidLoginFilterReinstateIpTaskIntervalInMin
        zimbraItemActionBatchSize
        zimbraLastPurgeMaxDuration
        zimbraLdapGentimeFractionalSecondsEnabled
        zimbraLmtpBindOnStartup
        zimbraLmtpBindPort
        zimbraLmtpExposeVersionOnBanner
        zimbraLmtpLHLORequired
        zimbraLmtpNumThreads
        zimbraLmtpPermanentFailureWhenOverQuota
        zimbraLmtpServerEnabled
        zimbraLmtpShutdownGraceSeconds
        zimbraLogToSyslog
        zimbraLowestSupportedAuthVersion
        zimbraMailClearTextPasswordEnabled
        zimbraMailContentMaxSize
        zimbraMailDiskStreamingThreshold
        zimbraMailEmptyFolderBatchSize
        zimbraMailEmptyFolderBatchThreshold
        zimbraMailFileDescriptorBufferSize
        zimbraMailFileDescriptorCacheSize
        zimbraMailKeepOutWebCrawlers
        zimbraMailLocalBind
        zimbraMailMode
        zimbraMailPort
        zimbraMailProxyMaxFails
        zimbraMailProxyPort
        zimbraMailProxyReconnectTimeout
        zimbraMailPurgeBatchSize
        zimbraMailPurgeSleepInterval
        zimbraMailRedirectSetEnvelopeSender
        zimbraMailReferMode
        zimbraMailSSLClientCertMode
        zimbraMailSSLClientCertOCSPEnabled
        zimbraMailSSLClientCertPort
        zimbraMailSSLPort
        zimbraMailSSLProxyClientCertPort
        zimbraMailSSLProxyPort
        zimbraMailTrustedIP
        zimbraMailURL
        zimbraMailUncompressedCacheMaxBytes
        zimbraMailUncompressedCacheMaxFiles
        zimbraMailUseDirectBuffers
        zimbraMailboxMoveFailedCleanupTaskInterval
        zimbraMailboxMoveSkipBlobs
        zimbraMailboxMoveSkipHsmBlobs
        zimbraMailboxMoveSkipSearchIndex
        zimbraMailboxMoveTempDir
        zimbraMailboxThrottleReapInterval
        zimbraMailboxdSSLProtocols
        zimbraMailboxdSSLRenegotiationAllowed
        zimbraMemcachedBindPort
        zimbraMemcachedClientBinaryProtocolEnabled
        zimbraMemcachedClientExpirySeconds
        zimbraMemcachedClientHashAlgorithm
        zimbraMemcachedClientTimeoutMillis
        zimbraMessageCacheSize
        zimbraMessageChannelEnabled
        zimbraMessageChannelPort
        zimbraMilterBindPort
        zimbraMilterMaxConnections
        zimbraMilterNumThreads
        zimbraMilterServerEnabled
        zimbraMobileMaxMessageSize
        zimbraMobileMetadataRetentionPolicy
        zimbraMtaAddressVerifyNegativeRefreshTime
        zimbraMtaAddressVerifyPollCount
        zimbraMtaAddressVerifyPollDelay
        zimbraMtaAddressVerifyPositiveRefreshTime
        zimbraMtaAliasMaps
        zimbraMtaAlwaysAddMissingHeaders
        zimbraMtaAntiSpamLockMethod
        zimbraMtaAuthEnabled
        zimbraMtaAuthPort
        zimbraMtaAuthTarget
        zimbraMtaBounceNoticeRecipient
        zimbraMtaBounceQueueLifetime
        zimbraMtaBrokenSaslAuthClients
        zimbraMtaCanonicalMaps
        zimbraMtaCommandDirectory
        zimbraMtaDaemonDirectory
        zimbraMtaDefaultProcessLimit
        zimbraMtaDelayWarningTime
        zimbraMtaDnsLookupsEnabled
        zimbraMtaEnableSmtpdPolicyd
        zimbraMtaHeaderChecks
        zimbraMtaHopcountLimit
        zimbraMtaInFlowDelay
        zimbraMtaLmdbMapSize
        zimbraMtaLmtpConnectionCacheTimeLimit
        zimbraMtaLmtpHostLookup
        zimbraMtaLmtpTlsCiphers
        zimbraMtaLmtpTlsLoglevel
        zimbraMtaLmtpTlsMandatoryCiphers
        zimbraMtaLmtpTlsMandatoryProtocols
        zimbraMtaLmtpTlsProtocols
        zimbraMtaLmtpTlsSecurityLevel
        zimbraMtaMailqPath
        zimbraMtaManpageDirectory
        zimbraMtaMaxUse
        zimbraMtaMaximalBackoffTime
        zimbraMtaMaximalQueueLifetime
        zimbraMtaMilterCommandTimeout
        zimbraMtaMilterConnectTimeout
        zimbraMtaMilterContentTimeout
        zimbraMtaMilterDefaultAction
        zimbraMtaMinimalBackoffTime
        zimbraMtaMyDestination
        zimbraMtaMyNetworks
        zimbraMtaNewaliasesPath
        zimbraMtaNotifyClasses
        zimbraMtaPolicyTimeLimit
        zimbraMtaPostscreenAccessList
        zimbraMtaPostscreenBareNewlineAction
        zimbraMtaPostscreenBareNewlineEnable
        zimbraMtaPostscreenBareNewlineTTL
        zimbraMtaPostscreenBlacklistAction
        zimbraMtaPostscreenCacheCleanupInterval
        zimbraMtaPostscreenCacheRetentionTime
        zimbraMtaPostscreenCommandCountLimit
        zimbraMtaPostscreenDnsblAction
        zimbraMtaPostscreenDnsblMaxTTL
        zimbraMtaPostscreenDnsblMinTTL
        zimbraMtaPostscreenDnsblTTL
        zimbraMtaPostscreenDnsblThreshold
        zimbraMtaPostscreenDnsblTimeout
        zimbraMtaPostscreenDnsblWhitelistThreshold
        zimbraMtaPostscreenGreetAction
        zimbraMtaPostscreenGreetTTL
        zimbraMtaPostscreenNonSmtpCommandAction
        zimbraMtaPostscreenNonSmtpCommandEnable
        zimbraMtaPostscreenNonSmtpCommandTTL
        zimbraMtaPostscreenPipeliningAction
        zimbraMtaPostscreenPipeliningEnable
        zimbraMtaPostscreenPipeliningTTL
        zimbraMtaPostscreenWatchdogTimeout
        zimbraMtaPostscreenWhitelistInterfaces
        zimbraMtaPropagateUnmatchedExtensions
        zimbraMtaQueueDirectory
        zimbraMtaQueueRunDelay
        zimbraMtaRestriction
        zimbraMtaSaslAuthEnable
        zimbraMtaSaslSmtpdMechList
        zimbraMtaSendmailPath
        zimbraMtaSmtpCnameOverridesServername
        zimbraMtaSmtpDnsSupportLevel
        zimbraMtaSmtpHeloName
        zimbraMtaSmtpSaslAuthEnable
        zimbraMtaSmtpSaslSecurityOptions
        zimbraMtaSmtpTlsCiphers
        zimbraMtaSmtpTlsDaneInsecureMXPolicy
        zimbraMtaSmtpTlsLoglevel
        zimbraMtaSmtpTlsMandatoryCiphers
        zimbraMtaSmtpTlsMandatoryProtocols
        zimbraMtaSmtpTlsProtocols
        zimbraMtaSmtpTlsSecurityLevel
        zimbraMtaSmtpTransportRateDelay
        zimbraMtaSmtpdBanner
        zimbraMtaSmtpdClientAuthRateLimit
        zimbraMtaSmtpdClientPortLogging
        zimbraMtaSmtpdClientRestrictions
        zimbraMtaSmtpdDataRestrictions
        zimbraMtaSmtpdErrorSleepTime
        zimbraMtaSmtpdHardErrorLimit
        zimbraMtaSmtpdHeloRequired
        zimbraMtaSmtpdProxyTimeout
        zimbraMtaSmtpdRejectUnlistedRecipient
        zimbraMtaSmtpdRejectUnlistedSender
        zimbraMtaSmtpdSaslAuthenticatedHeader
        zimbraMtaSmtpdSaslSecurityOptions
        zimbraMtaSmtpdSaslTlsSecurityOptions
        zimbraMtaSmtpdSoftErrorLimit
        zimbraMtaSmtpdTlsAskCcert
        zimbraMtaSmtpdTlsCcertVerifydepth
        zimbraMtaSmtpdTlsCiphers
        zimbraMtaSmtpdTlsLoglevel
        zimbraMtaSmtpdTlsMandatoryCiphers
        zimbraMtaSmtpdTlsMandatoryProtocols
        zimbraMtaSmtpdTlsProtocols
        zimbraMtaSmtpdTlsReceivedHeader
        zimbraMtaSmtpdVirtualTransport
        zimbraMtaStpdSoftErrorLimit
        zimbraMtaTlsAppendDefaultCA
        zimbraMtaTlsAuthOnly
        zimbraMtaTlsSecurityLevel
        zimbraMtaTransportMaps
        zimbraMtaUnverifiedRecipientDeferCode
        zimbraMtaVirtualAliasDomains
        zimbraMtaVirtualAliasExpansionLimit
        zimbraMtaVirtualAliasMaps
        zimbraMtaVirtualMailboxDomains
        zimbraMtaVirtualMailboxMaps
        zimbraNetworkAdminEnabled
        zimbraNetworkAdminNGEnabled
        zimbraNetworkMobileNGEnabled
        zimbraNetworkModulesNGEnabled
        zimbraNotebookFolderCacheSize
        zimbraNotebookMaxCachedTemplatesPerFolder
        zimbraNotebookPageCacheSize
        zimbraNotifyBindPort
        zimbraNotifySSLBindPort
        zimbraNotifySSLServerEnabled
        zimbraNotifyServerEnabled
        zimbraOpenImapFolderRequestChunkSize
        zimbraOpenidConsumerStatelessModeEnabled
        zimbraPop3BindOnStartup
        zimbraPop3BindPort
        zimbraPop3CleartextLoginEnabled
        zimbraPop3ExposeVersionOnBanner
        zimbraPop3MaxConnections
        zimbraPop3NumThreads
        zimbraPop3ProxyBindPort
        zimbraPop3SSLBindOnStartup
        zimbraPop3SSLBindPort
        zimbraPop3SSLProxyBindPort
        zimbraPop3SSLServerEnabled
        zimbraPop3SaslGssapiEnabled
        zimbraPop3ServerEnabled
        zimbraPop3ShutdownGraceSeconds
        zimbraPrevFoldersToTrackMax
        zimbraRedoLogArchiveDir
        zimbraRedoLogCrashRecoveryLookbackSec
        zimbraRedoLogDeleteOnRollover
        zimbraRedoLogEnabled
        zimbraRedoLogFsyncIntervalMS
        zimbraRedoLogLogPath
        zimbraRedoLogRolloverFileSizeKB
        zimbraRedoLogRolloverHardMaxFileSizeKB
        zimbraRedoLogRolloverMinFileAge
        zimbraRemoteImapBindPort
        zimbraRemoteImapSSLBindPort
        zimbraRemoteImapSSLServerEnabled
        zimbraRemoteImapServerEnabled
        zimbraRemoteManagementCommand
        zimbraRemoteManagementPort
        zimbraRemoteManagementPrivateKeyPath
        zimbraRemoteManagementUser
        zimbraReverseProxyAcceptMutex
        zimbraReverseProxyAdminEnabled
        zimbraReverseProxyAvailableLookupTargets
        zimbraReverseProxyClientCertMode
        zimbraReverseProxyConnectTimeout
        zimbraReverseProxyDnsLookupInServerEnabled
        zimbraReverseProxyExactServerVersionCheck
        zimbraReverseProxyGenConfigPerVirtualHostname
        zimbraReverseProxyHttpEnabled
        zimbraReverseProxyIPThrottleWhitelistTime
        zimbraReverseProxyImapEnabledCapability
        zimbraReverseProxyImapExposeVersionOnBanner
        zimbraReverseProxyImapSaslGssapiEnabled
        zimbraReverseProxyImapSaslPlainEnabled
        zimbraReverseProxyImapStartTlsMode
        zimbraReverseProxyInactivityTimeout
        zimbraReverseProxyLogLevel
        zimbraReverseProxyLookupTarget
        zimbraReverseProxyMailEnabled
        zimbraReverseProxyMailImapEnabled
        zimbraReverseProxyMailImapsEnabled
        zimbraReverseProxyMailPop3Enabled
        zimbraReverseProxyMailPop3sEnabled
        zimbraReverseProxyPassErrors
        zimbraReverseProxyPop3EnabledCapability
        zimbraReverseProxyPop3ExposeVersionOnBanner
        zimbraReverseProxyPop3SaslGssapiEnabled
        zimbraReverseProxyPop3SaslPlainEnabled
        zimbraReverseProxyPop3StartTlsMode
        zimbraReverseProxyRouteLookupTimeout
        zimbraReverseProxyRouteLookupTimeoutCache
        zimbraReverseProxySNIEnabled
        zimbraReverseProxySSLCiphers
        zimbraReverseProxySSLProtocols
        zimbraReverseProxySSLSessionCacheSize
        zimbraReverseProxySSLSessionTimeout
        zimbraReverseProxySSLToUpstreamEnabled
        zimbraReverseProxyStrictServerNameEnabled
        zimbraReverseProxyUpstreamConnectTimeout
        zimbraReverseProxyUpstreamEwsServers
        zimbraReverseProxyUpstreamFairShmSize
        zimbraReverseProxyUpstreamLoginServers
        zimbraReverseProxyUpstreamPollingTimeout
        zimbraReverseProxyUpstreamReadTimeout
        zimbraReverseProxyUpstreamSendTimeout
        zimbraReverseProxyWorkerConnections
        zimbraReverseProxyWorkerProcesses
        zimbraReverseProxyXmppBoshEnabled
        zimbraReverseProxyXmppBoshLocalHttpBindURL
        zimbraReverseProxyXmppBoshSSL
        zimbraReverseProxyXmppBoshTimeout
        zimbraReverseProxyZmlookupCachingEnabled
        zimbraSSLCertificate
        zimbraSSLExcludeCipherSuites
        zimbraSSLPrivateKey
        zimbraSaslGssapiRequiresTls
        zimbraScheduledTaskNumThreads
        zimbraServerVersion
        zimbraServerVersionBuild
        zimbraServerVersionMajor
        zimbraServerVersionMicro
        zimbraServerVersionMinor
        zimbraServerVersionType
        zimbraServiceEnabled
        zimbraServiceHostname
        zimbraServiceInstalled
        zimbraShareNotificationMtaAuthRequired
        zimbraShareNotificationMtaConnectionType
        zimbraShareNotificationMtaEnabled
        zimbraSharingUpdatePublishInterval
        zimbraShortTermAllEffectiveRightsCacheExpiration
        zimbraShortTermAllEffectiveRightsCacheSize
        zimbraShortTermGranteeCacheExpiration
        zimbraShortTermGranteeCacheSize
        zimbraSieveFeatureVariablesEnabled
        zimbraSieveRejectEnabled
        zimbraSmimeOCSPEnabled
        zimbraSmtpHostname
        zimbraSmtpPort
        zimbraSmtpSendPartial
        zimbraSmtpTimeout
        zimbraSoapExposeVersion
        zimbraSoapRequestMaxSize
        zimbraSpellAvailableDictionary
        zimbraSpellCheckURL
        zimbraSshPublicKey
        zimbraStatThreadNamePrefix
        zimbraTableMaintenanceGrowthFactor
        zimbraTableMaintenanceMaxRows
        zimbraTableMaintenanceMinRows
        zimbraTableMaintenanceOperation
        zimbraThreadMonitorEnabled
        zimbraVirusDefinitionsUpdateFrequency
        zimbraWebGzipEnabled
        zimbraXMPPEnabled
        zimbraZimletJspEnabled
      ]
      attr_accessor *INSTANCE_VARIABLE_KEYS
      attr_accessor :name, :id

      def mta_queues
        @mta_queues ||= mta_queues!
      end

      def mta_queues!
        MtaQueuesCollection.new self
      end

      def backups
        @backups ||= backups!
      end

      def backups!
        BackupsCollection.new self
      end

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
