require 'zm/modules/common/account_common'
# require_relative '../../modules/common/account_galsync'
require 'zm/client/connector/rest_account'
require 'zm/client/folder'
require 'zm/client/share'
require 'zm/client/tag'
# require 'zm/client/contact'
# require 'zm/client/appointment'
# require 'zm/client/task'
# require 'zm/client/data_source'
# require 'zm/client/message'
require 'addressable/uri'

module Zm
  module Client
    # objectClass: zimbraAccount
    class Account < Base::Object

      attr_reader :name, :id, :domainkey, :used, :token
      attr_accessor :password, :company, :zimbraCOSId, :zimbraMailHost, :zimbraMailTransport, :carLicense

      def initialize(parent)
        extend(AccountCommon)
        super(parent)
      end

      def rest_account_connector
        @rest_account_connector ||= RestAccountConnector.new
      end

      alias rac rest_account_connector

      def logged?
        !@token.nil?
      end

      def login
        # TODO: faire un if admin_connector alors admin_login sinon
        # account_login afin de n'utiliser qu'un seul appel de login
        @token = sacc.auth(@name, @domainkey)
      end

      def account_login(key = nil)
        @domainkey = key || domain_key
        @token = sacc.auth(@name, @domainkey)
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
          @infos = sacc.get_info(@token)[:Body][:GetInfoResponse]
          @id          ||= @infos[:id]
          @used        ||= @infos[:used]
          @public_url  ||= @infos[:publicURL]
          @zimbraCOSId ||= @infos[:cos][:id]
          @home_url    ||= @infos[:rest]
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
        @shares ||= SharesCollection.new(self)
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
        @tags ||= TagsCollection.new(self)
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
        rep = sac.create_account(
          @name,
          @password,
          instance_variables_array(attrs_write)
        )
        @id = rep[:Body][:CreateAccountResponse][:account].first[:id]
      end

      def aliases
        @aliases ||= []
      end

      def add_alias!(email)
        sac.add_account_alias(@id, email)
        aliases.push(email)
      end

      def remove_alias!(email)
        sac.remove_account_alias(@id, email)
        aliases.delete(email)
      end

      def download(folder_path, fmt, types, dest_file_path)
        url_folder_path = File.join(@home_url, folder_path.to_s)
        uri = Addressable::URI.new
        uri.query_values = {
            fmt: fmt,
            types: types.join(','),
            emptyname: 'Vide',
            charset: 'UTF-8',
            auth: 'qp',
            zauthtoken: @token
        }
        url_folder_path << '?' << uri.query

        rac.download(url_folder_path, dest_file_path)
      end

      def upload(folder_path, fmt, types, resolve, src_file_path)
        url_folder_path = File.join(@home_url, folder_path.to_s)
        uri = Addressable::URI.new
        uri.query_values = {
            fmt: fmt,
            types: types.join(','),
            resolve: resolve,
            auth: 'qp',
            zauthtoken: @token
        }
        url_folder_path << '?' << uri.query

        rac.upload(url_folder_path, src_file_path)
      end
    end
  end
end
