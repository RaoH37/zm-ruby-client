# frozen_string_literal: true

require 'zm/client/account/account_aliases_collection'

module Zm
  module Client
    # objectClass: zimbraAccount
    class Account < Base::MailboxObject
      include RequestMethodsAdmin

      # #################################################################
      # Associations
      # #################################################################

      def aliases
        @aliases ||= AccountAliasesCollection.new(self)
      end

      def cos
        @cos ||= @parent.coses.find_by(id: zimbraCOSId)
      end

      # #################################################################
      # SOAP Actions
      # #################################################################

      def create!
        resp = sac.invoke(build_create)
        @id = resp[:CreateAccountResponse][:account].first[:id]
      end

      def created_at
        @created_at ||= Time.parse(zimbraCreateTimestamp) unless zimbraCreateTimestamp.nil?
      end

      def flush_cache!
        sac.invoke(build_flush_cache)
        true
      end

      def build_flush_cache
        soap_request = SoapElement.admin(SoapAdminConstants::FLUSH_CACHE_REQUEST)
        node_cache = SoapElement.create('cache').add_attributes({ type: SoapConstants::ACCOUNT, allServers: 1 })
        soap_request.add_node(node_cache)
        node_entry = SoapElement.create('entry').add_attribute(SoapConstants::BY, SoapConstants::ID).add_content(@id)
        node_cache.add_node(node_entry)
        soap_request
      end

      def attrs_write
        @parent.zimbra_attributes.all_account_attrs_writable_names
      end

      def jsns_builder
        @jsns_builder ||= AccountJsnsBuilder.new(self)
      end

      def batch
        return @batch if defined? @batch

        @batch = BatchRequest.new(soap_account_connector)
      end

      private

      def do_update!(hash)
        sac.invoke(jsns_builder.to_patch(hash))
      end
    end
  end
end
