require 'zm/modules/common/resource_common'

module Zm
  module Client
    # objectClass: zimbraCalendarResource
    class Resource < Base::Object

      attr_reader :name, :id, :domainkey, :used, :token

      def initialize(parent)
        extend(ResourceCommon)
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

      def delete!
        sac.delete_resource(@id)
      end

      def update!(hash)
        sac.modify_resource(@id, hash)
        hash.each { |k, v| send "#{k}=", v }
      end

      def modify!
        sac.modify_resource(
          @id,
          instance_variables_array(attrs_write)
        )
      end

      def create!
        rep = sac.create_resource(
          @name,
          @password,
          instance_variables_array(attrs_write)
        )
        @id = rep[:Body][:CreateCalendarResourceResponse][:calresource].first[:id]
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
