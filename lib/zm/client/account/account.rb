# require_relative '../../modules/common/account_common'
# require_relative '../../modules/common/account_galsync'
# require 'zm/client/connector/rest_account'
# require 'zm/client/folder'
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
      attr_accessor :company, :zimbraCOSId, :zimbraMailHost

      def logged?
        !@token.nil?
      end

      def login
        # TODO: faire un if admin_connector alors admin_login sinon
        # account_login afin de n'utiliser qu'un seul appel de login
        @token = @soap_account_connector.auth(@name, @domainkey)
      end

      def account_login(domainkey = nil)
        @domainkey = domainkey
        @token = @soap_account_connector.auth(@name, @domainkey)
      end

      def admin_login
        @token = sac.delegate_auth(@name)
      end

      def domain_name
        @name.split('@').last
      end

      def infos
        if @infos.nil?
          @infos = @soap_account_connector.get_info(@token)[:Body][:GetInfoResponse]
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
          @soap_account_connector, self
        )
      end

      def shares
        @shares ||= SharesCollection.new(
          @soap_account_connector, self
        )
      end

      def contacts
        @contacts ||= ContactsCollection.new(
          @soap_account_connector, self
        )
      end

      def appointments
        @appointments ||= AppointmentsCollection.new(
          @soap_account_connector, self
        )
      end

      def tags
        @tags ||= TagsCollection.new(
          @soap_account_connector, self
        )
      end

      def tasks
        @tasks ||= TasksCollection.new(
          @soap_account_connector, self
        )
      end

      def data_sources
        @data_sources ||= DataSourcesCollection.new soap_admin_connector, self
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
