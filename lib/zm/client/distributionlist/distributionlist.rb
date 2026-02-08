# frozen_string_literal: true

module Zm
  module Client
    # objectClass: zimbraDistributionList
    class DistributionList < Base::Object
      include Zm::Utils::HasSoapAdminConnector
      include SoapRequest::RequestMethodsAdmin

      def aliases
        return @aliases if defined? @aliases

        @aliases = DistributionListAliasesCollection.new(self)
      end

      def members
        return @members if defined? @members

        @members = DistributionListMembersCollection.new(self)
      end

      def owners
        return @owners if defined? @owners

        @owners = DistributionListOwnersCollection.new(self)
      end

      def memberships
        return @memberships if defined? @memberships

        @memberships = DlsMembershipCollection.new(self)
      end

      def aces
        return @aces if defined? @aces

        @aces = DistributionListAcesCollection.new(self)
      end

      def create!
        resp = sac.invoke(build_create)
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

      def attrs_write
        @parent.zimbra_attributes.all_distributionlist_attrs_writable_names
      end

      def jsns_builder
        return @jsns_builder if defined? @jsns_builder

        @jsns_builder = DistributionListJsnsBuilder.new(self)
      end
    end
  end
end
