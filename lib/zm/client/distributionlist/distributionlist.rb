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
        rep = sac.jsns_request(:CreateDistributionListRequest, jsns_builder.to_jsns)
        @id = rep[:Body][:CreateDistributionListResponse][:dl].first[:id]
      end

      def modify!
        sac.jsns_request(:ModifyDistributionListRequest, jsns_builder.to_update)
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

      def rename!(email)
        # sac.rename_distribution_list(@id, email)

        soap_request = SoapElement.admin(SoapAdminConstants::RENAME_DISTRIBUTION_LIST_REQUEST)
        soap_request.add_attributes({ id: @id, newName: email })
        sac.invoke(soap_request)

        @name = email
      end

      def delete!
        sac.jsns_request(:DeleteDistributionListRequest, { id: @id })
        @id = nil
      end

      def local_transport
        raise Zm::Client::SoapError, 'zimbraMailHost is null' if zimbraMailHost.nil?

        "lmtp:#{zimbraMailHost}:7025"
      end

      def local_transport!
        update!(zimbraMailTransport: local_transport)
      end

      def local_transport?
        return nil unless zimbraMailTransport

        zimbraMailTransport.start_with?('lmtp')
      end

      def external_transport?
        return nil unless zimbraMailTransport

        zimbraMailTransport.start_with?('smtp')
      end

      def hide_in_gal?
        zimbraHideInGal == 'TRUE'
      end

      def group?
        zimbraMailStatus == 'disabled'
      end

      def mailing_list?
        zimbraMailStatus == 'enabled'
      end

      def attrs_write
        @parent.zimbra_attributes.all_distributionlist_attrs_writable_names
      end

      private

      def do_update!(hash)
        sac.jsns_request(:ModifyDistributionListRequest, jsns_builder.to_patch(hash))
      end

      def jsns_builder
        @jsns_builder ||= DistributionListJsnsBuilder.new(self)
      end
    end
  end
end
