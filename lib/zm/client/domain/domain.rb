# frozen_string_literal: true

module Zm
  module Client
    # objectClass: zimbraDomain
    class Domain < Base::Object
      extend Zm::Relationship
      include Zm::Utils::HasSoapAdminConnector
      include SoapRequest::RequestMethodsAdmin

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
        return @jsns_builder if defined? @jsns_builder

        @jsns_builder = DomainJsnsBuilder.new(self)
      end
    end
  end
end
