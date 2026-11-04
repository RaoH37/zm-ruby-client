# frozen_string_literal: true

module Zm
  module Client
    # objectClass: zimbraDistributionList
    class DistributionList < Base::Object
      extend Relationship

      has_jsns_builder
      include Zm::Utils::HasSoapAdminConnector
      include SoapRequest::RequestMethodsAdmin
      extend Base::HasZimbraAttributes

      zimbra_attr %i[
        cn description displayName zimbraMailHost zimbraNotes zimbraMailForwardingAddress zimbraMailStatus
        zimbraPrefReplyToAddress zimbraLocale zimbraHideInGal zimbraPrefReplyToDisplay zimbraPrefReplyToEnabled
        zimbraACE zimbraAdminConsoleUIComponents zimbraPrefAllowAddressForDelegatedSender
        zimbraDistributionListSendShareMessageToNewMembers
      ]

      zimbra_attr %i[mail uid zimbraId zimbraMailAlias zimbraCreateTimestamp], readonly: true

      has_many :aliases, klass: :'Zm::Client::DistributionListAliasesCollection'
      has_many :members, klass: :'Zm::Client::DistributionListMembersCollection'
      has_many :owners, klass: :'Zm::Client::DistributionListOwnersCollection'
      has_many :memberships, klass: :'Zm::Client::DlsMembershipCollection'
      has_many :aces, klass: :'Zm::Client::DistributionListAcesCollection'

      def create!
        resp = sac.invoke(build_create)
        clear_zimbra_attrs_changes
        @id = resp[:CreateDistributionListResponse][:dl].first[:id]
      end

      def local_transport
        raise Zm::Error::ZmError, 'zimbraMailHost is null' if zimbraMailHost.nil?

        "lmtp:#{zimbraMailHost}:7025"
      end

      def local_transport!
        update!(zimbraMailTransport: local_transport)
      end

      def local_transport?
        return false unless zimbraMailTransport

        zimbraMailTransport.start_with?(SoapRequest::SoapConstants::LMTP)
      end

      def external_transport?
        return false unless zimbraMailTransport

        zimbraMailTransport.start_with?(SoapRequest::SoapConstants::SMTP)
      end

      def hide_in_gal?
        zimbraHideInGal == SoapRequest::SoapConstants::TRUE
      end

      def group?
        zimbraMailStatus == SoapRequest::SoapConstants::DISABLED
      end

      def mailing_list?
        zimbraMailStatus == SoapRequest::SoapConstants::ENABLED
      end
    end
  end
end
