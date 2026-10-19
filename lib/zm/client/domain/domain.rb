# frozen_string_literal: true

module Zm
  module Client
    # objectClass: zimbraDomain
    class Domain < Base::Object
      extend Zm::Relationship
      has_jsns_builder
      include Zm::Utils::HasSoapAdminConnector
      include SoapRequest::RequestMethodsAdmin
      extend Base::HasZimbraAttributes

      zimbra_attr %i[
        description zimbraNotes zimbraMailStatus zimbraPrefTimeZoneId zimbraMailTransport zimbraLocale zimbraPrefSkin
        zimbraAvailableSkin zimbraFreebusyExchangeURL zimbraFreebusyExchangeAuthUsername
        zimbraFreebusyExchangeAuthPassword zimbraFreebusyExchangeUserOrg zimbraFreebusyExchangeAuthScheme
        zimbraFreebusyExchangeCachedIntervalStart zimbraFreebusyExchangeCachedInterval zimbraACE
        zimbraReverseProxyUseExternalRoute zimbraExternalPop3Port zimbraExternalPop3SSLPort zimbraExternalImapPort
        zimbraExternalImapSSLPort zimbraExternalPop3Hostname zimbraExternalPop3SSLHostname zimbraExternalImapHostname
        zimbraExternalImapSSLHostname zimbraPrefSpellIgnoreWord zimbraPrefMailTrustedSenderList
        zimbraMailTrustedSenderListMaxNumEntries zimbraFeatureCalendarReminderDeviceEmailEnabled
        zimbraCalendarLocationDisabledFields zimbraExternalSharingEnabled zimbraExternalShareWhitelistDomain
        zimbraExternalShareDomainWhitelistEnabled zimbraStandardClientCustomPrefTabsEnabled
        zimbraStandardClientCustomPrefTab zimbraInternalSendersDomain zimbraFileUploadMaxSizePerFile
        zimbraPublicSharingEnabled zimbraUCServiceId zimbraPrefColorMessagesEnabled zimbraMobileMetadataMaxSizeEnabled
        zimbraMobileItemsToTrackPerFolderMaxSize zimbraForceClearCookies zimbraFeatureDistributionListFolderEnabled
        zimbraFeatureSocialEnabled zimbraFeatureSocialExternalEnabled zimbraFeatureSocialExternalURL
        zimbraFeatureSocialName zimbraCommunityAPIClientID zimbraCommunityAPIClientSecret zimbraCommunityUsernameMapping
        zimbraCommunityBaseURL zimbraCommunityHomeURL zimbraPrefShowChatsFolderInMail
        zimbraZimletUserPropertiesMaxNumEntries zimbraExportMaxDays zimbraSieveRejectMailEnabled
        zimbraSieveNotifyActionRFCCompliant zimbraAdminSieveScriptBefore zimbraAdminSieveScriptAfter
        zimbraAdminOutgoingSieveScriptBefore zimbraAdminOutgoingSieveScriptAfter zimbraSieveRequireControlEnabled
        zimbraSieveEditHeaderEnabled zimbraSieveImmutableHeaders zimbraPreAuthKey zimbraGalAccountId
        zimbraGalAlwaysIncludeLocalCalendarResources zimbraGalAutoCompleteLdapFilter zimbraGalGroupIndicatorEnabled
        zimbraGalInternalSearchBase zimbraGalLdapAttrMap zimbraGalLdapPageSize zimbraGalLdapValueMap zimbraGalMaxResults
        zimbraGalMode zimbraGalSyncLdapPageSize zimbraGalSyncMaxConcurrentClients zimbraGalSyncSizeLimit
        zimbraGalSyncTimestampFormat zimbraGalTokenizeAutoCompleteKey zimbraGalTokenizeSearchKey
        zimbraLdapGalSyncDisabled zimbraGalLdapBindDn zimbraGalLdapBindPassword zimbraGalLdapFilter
        zimbraGalLdapSearchBase zimbraGalLdapURL zimbraDomainDefaultCOSId zimbraPublicServiceHostname
        zimbraPublicServiceProtocol zimbraAdminConsoleCatchAllAddressEnabled zimbraAdminConsoleDNSCheckEnabled
        zimbraAdminConsoleLDAPAuthEnabled zimbraAdminConsoleSkinEnabled zimbraAggregateQuotaLastUsage zimbraAuthMech
        zimbraAutoProvBatchSize zimbraAutoProvNotificationBody zimbraAutoProvNotificationSubject zimbraBasicAuthRealm
        zimbraChatConversationAuditEnabled zimbraDomainAggregateQuota zimbraDomainAggregateQuotaPolicy
        zimbraDomainAggregateQuotaWarnPercent zimbraDomainMandatoryMailSignatureEnabled zimbraDomainStatus
        zimbraExternalShareInvitationUrlExpiration zimbraFreebusyExchangeServerType
        zimbraInternalSharingCrossDomainEnabled zimbraMailDomainQuota zimbraMailSSLClientCertPrincipalMap
        zimbraReverseProxyClientCertMode zimbraReverseProxyExternalRouteIncludeOriginalAuthusername
        zimbraSkinLogoAppBanner zimbraSkinLogoLoginBanner zimbraSkinLogoURL zimbraWebClientMaxInputBufferLength
        zimbraWebClientStaySignedInDisabled zimbraWebClientSupportedHelps zimbraZimletDataSensitiveInMixedModeDisabled
        DKIMDomain DKIMIdentity DKIMKey DKIMPublicKey DKIMSelector zimbraShowClientTOS
      ]

      zimbra_attr %i[
        zimbraId zimbraCreateTimestamp zimbraGalDefinitionLastModifiedTime zimbraDomainName zimbraDomainType
      ], readonly: true

      def create!
        resp = sac.invoke(build_create)
        @id = resp[:CreateDomainResponse][:domain].first[:id]
      end

      has_many :accounts, klass: :'Zm::Client::DomainAccountsCollection'
      has_many :distribution_lists, klass: :'Zm::Client::DomainDistributionListsCollection'
      alias distributionlists distribution_lists

      has_many :resources, klass: :'Zm::Client::DomainResourcesCollection'

      def cos
        return nil if zimbraDomainDefaultCOSId.nil?

        return @cos if defined? @cos

        @cos = @parent.coses.find_by(id: zimbraDomainDefaultCOSId)
      end

      def DKIMPublicTxt
        return if self.DKIMPublicKey.nil?
        return @DKIMPublicTxt if @DKIMPublicTxt

        txt = self.DKIMPublicKey.each_line.map do |line|
          line.chomp!
          line.gsub!('"', '')
          line.strip!
        end.join

        matches = txt.scan(/\((.*)\)/)
        return if matches.first.nil?

        @DKIMPublicTxt = matches.first.first.strip
      end
    end
  end
end
