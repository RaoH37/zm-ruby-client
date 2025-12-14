# frozen_string_literal: true

require 'zm/client/distributionlist/distributionlist_aliases_collection'
require 'zm/client/distributionlist/distributionlist_members_collection'
require 'zm/client/distributionlist/distributionlist_owners_collection'
require 'zm/client/distributionlist/distributionlist_aces_collection'

module Zm
  module Client
    # objectClass: zimbraDistributionList
    class DistributionList < Base::Object
      include HasSoapAdminConnector
      include RequestMethodsAdmin

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
        raise Zm::Client::ZmError, 'zimbraMailHost is null' if zimbraMailHost.nil?

        "lmtp:#{zimbraMailHost}:7025"
      end

      def local_transport!
        update!(zimbraMailTransport: local_transport)
      end

      def local_transport?
        return nil unless zimbraMailTransport

        zimbraMailTransport.start_with?(SoapConstants::LMTP)
      end

      def external_transport?
        return nil unless zimbraMailTransport

        zimbraMailTransport.start_with?(SoapConstants::SMTP)
      end

      def hide_in_gal?
        zimbraHideInGal == SoapConstants::TRUE
      end

      def group?
        zimbraMailStatus == SoapConstants::DISABLED
      end

      def mailing_list?
        zimbraMailStatus == SoapConstants::ENABLED
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
