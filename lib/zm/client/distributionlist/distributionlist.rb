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

      def aliases
        @aliases ||= DistributionListAliasesCollection.new(self)
      end

      def members
        @members ||= DistributionListMembersCollection.new(self)
      end

      def owners
        @owners ||= DistributionListOwnersCollection.new(self)
      end

      def memberships
        @memberships ||= DlsMembershipCollection.new(self)
      end

      def aces
        @aces ||= DistributionListAcesCollection.new(self)
      end

      def create!
        resp = sac.invoke(jsns_builder.to_create)
        @id = resp[:CreateDistributionListResponse][:dl].first[:id]
      end

      def modify!
        sac.invoke(jsns_builder.to_update)
        true
      end

      def update!(hash)
        return false if hash.delete_if { |k, v| v.nil? || !respond_to?(k) }.empty?

        do_update!(hash)

        hash.each do |key, value|
          update_attribute(key, value)
        end

        true
      end

      def rename!(new_name)
        sac.invoke(jsns_builder.to_rename(new_name))
        @name = new_name
      end

      def delete!
        sac.invoke(jsns_builder.to_delete)
        @id = nil
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

      private

      def do_update!(hash)
        sac.invoke(jsns_builder.to_patch(hash))
      end

      def jsns_builder
        @jsns_builder ||= DistributionListJsnsBuilder.new(self)
      end
    end
  end
end
