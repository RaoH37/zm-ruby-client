# require_relative '../../modules/common/account_common'
# require_relative '../../modules/common/account_galsync'
# require 'zm/client/connector/rest_account'
require 'zm/client/folder'
# require 'zm/client/share'
# require 'zm/client/contact'
# require 'zm/client/appointment'
# require 'zm/client/task'
# require 'zm/client/data_source'
# require 'zm/client/message'

module Zm
  module Client
    # objectClass: zimbraAccount
    class Account < Base::Object
      attr_reader :name, :id, :domainkey, :used, :token
      attr_accessor :company, :zimbraCOSId, :zimbraMailHost, :zimbraMailTransport

      def logged?
        !@token.nil?
      end

      def login
        # TODO: faire un if admin_connector alors admin_login sinon
        # account_login afin de n'utiliser qu'un seul appel de login
        @token = soap_account_connector.auth(@name, @domainkey)
      end

      def account_login(key = nil)
        @domainkey = key || domain_key
        @token = soap_account_connector.auth(@name, @domainkey)
      end

      def admin_login
        @token = sac.delegate_auth(@name)
      end

      def domain_name
        @name.split('@').last
      end

      def domain_key
        @parent.domain_key(domain_name)
      end

      def infos
        if @infos.nil?
          @infos = soap_account_connector.get_info(@token)[:Body][:GetInfoResponse]
          @id          ||= @infos[:id]
          @used        ||= @infos[:used]
          @public_url  ||= @infos[:publicURL]
          @zimbraCOSId ||= @infos[:cos][:id]
          # pertinence ?
          # @zimbraCOSName ||= @infos[:cos][:name]
        end
        @infos
      end

      def folders
        @folders ||= FoldersCollection.new(
          sacc, self
        )
      end

      def shares
        @shares ||= SharesCollection.new(
          sacc, self
        )
      end

      def contacts
        @contacts ||= ContactsCollection.new(
          sacc, self
        )
      end

      def appointments
        @appointments ||= AppointmentsCollection.new(
          sacc, self
        )
      end

      def tags
        @tags ||= TagsCollection.new(
          sacc, self
        )
      end

      def tasks
        @tasks ||= TasksCollection.new(
          sacc, self
        )
      end

      def data_sources
        @data_sources ||= DataSourcesCollection.new sac, self
      end

      def delete!
        sac.delete_account(@id)
      end

      def update!(hash)
        sac.modify_account(@id, hash)
        hash.each { |k, v| send "#{k}=", v }
      end

      def modify!
        sac.modify_account(
          @id,
          instance_variables_array(attrs_write)
        )
      end

      def create!
        sac.create_account(
          @name,
          instance_variables_array(attrs_write)
        )
      end
    end
  end
end
