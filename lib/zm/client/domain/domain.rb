# frozen_string_literal: true

module Zm
  module Client
    # objectClass: zimbraDomain
    class Domain < Base::Object
      include HasSoapAdminConnector

      def create!
        resp = sac.invoke(jsns_builder.to_create)
        @id = resp[:CreateDomainResponse][:domain].first[:id]
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

      def delete!
        soap_request = SoapElement.admin(SoapAdminConstants::DELETE_DOMAIN_REQUEST).add_attribute(SoapConstants::ID,
                                                                                                  @id)
        sac.invoke(soap_request)
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

      def cos
        return nil if self.zimbraDomainDefaultCOSId.nil?

        @cos ||= @parent.coses.find_by id: self.zimbraDomainDefaultCOSId
      end

      def attrs_write
        @parent.zimbra_attributes.all_domain_attrs_writable_names
      end

      private

      def do_update!(hash)
        sac.invoke(jsns_builder.to_patch(hash))
      end

      def jsns_builder
        @jsns_builder ||= DomainJsnsBuilder.new(self)
      end
    end
  end
end
