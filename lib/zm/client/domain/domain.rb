# frozen_string_literal: true

module Zm
  module Client
    # objectClass: zimbraDomain
    class Domain < Base::Object
      include HasSoapAdminConnector
      include RequestMethodsAdmin

      def create!
        resp = sac.invoke(build_create)
        @id = resp[:CreateDomainResponse][:domain].first[:id]
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
        return nil if zimbraDomainDefaultCOSId.nil?

        @cos ||= @parent.coses.find_by id: zimbraDomainDefaultCOSId
      end

      def attrs_write
        @parent.zimbra_attributes.all_domain_attrs_writable_names
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

      def jsns_builder
        @jsns_builder ||= DomainJsnsBuilder.new(self)
      end
    end
  end
end
