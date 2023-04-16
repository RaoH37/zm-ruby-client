# frozen_string_literal: true

module Zm
  module Client
    # objectClass: zimbraDomain
    class Domain < Base::Object
      include HasSoapAdminConnector

      def create!
        rep = sac.jsns_request(:CreateDomainRequest, jsns_builder.to_jsns)
        @id = rep[:Body][:CreateDomainResponse][:domain].first[:id]
      end

      def modify!
        sac.jsns_request(:ModifyDomainRequest, jsns_builder.to_update)
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

      def delete!
        sac.jsns_request(:DeleteDomainRequest, { id: @id })
        @id = nil
      end

      def accounts
        @accounts ||= DomainAccountsCollection.new(self)
      end

      def distributionlists
        @distributionlists ||= DomainDistributionListsCollection.new(self)
      end
      alias distribution_lists distributionlists

      def resources
        @resources ||= DomainResourcesCollection.new(self)
      end

      def attrs_write
        @parent.zimbra_attributes.all_domain_attrs_writable_names
      end

      private

      def do_update!(hash)
        sac.jsns_request(:ModifyDomainRequest, jsns_builder.to_patch(hash))
      end

      def jsns_builder
        @jsns_builder ||= DomainJsnsBuilder.new(self)
      end
    end
  end
end
