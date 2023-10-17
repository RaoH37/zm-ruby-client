# frozen_string_literal: true

require 'zm/modules/common/resource_common'

module Zm
  module Client
    # objectClass: zimbraCalendarResource
    class Resource < Base::AdminObject
      attr_accessor :home_url, :zimbraCalResAutoDeclineRecurring

      def initialize(parent)
        extend(ResourceCommon)
        super(parent)
        @grantee_type = 'usr'.freeze
      end

      def all_instance_variable_keys
        ResourceCommon::ALL_ATTRS
      end

      def rest_account_connector
        @rest_account_connector ||= RestAccountConnector.new
      end

      alias rac rest_account_connector

      def logged?
        !@token.nil?
      end

      def login
        if @parent.logged?
          admin_login
        else
          account_login
        end
      end

      def account_login_preauth
        domain_key
        raise ZmError, 'domain key is required to login !' if @domainkey.nil?

        @token = sacc.auth_preauth(@name, @domainkey)
      end

      def account_login_password
        raise ZmError, 'password is required to login !' if password.nil?

        @token = sacc.auth_password(@name, @password)
      end

      def admin_login
        @token = sac.delegate_auth(@name)
      end

      def domain_name
        @name.split('@').last
      end

      def domain_key
        @domainkey ||= @parent.domain_key(domain_name)
      end

      def infos
        @infos ||= read_infos
      end

      def read_infos
        @infos = sacc.get_info(@token)[:Body][:GetInfoResponse]
        @id = @infos[:id]
        @used = @infos[:used]
        @public_url = @infos[:publicURL]
        @zimbraCOSId = @infos[:cos][:id]
        @home_url = @infos[:rest]
      end

      def folders
        @folders ||= FoldersCollection.new(self)
      end

      def delete!
        sac.delete_resource(@id)
      end

      def update!(hash)
        sac.modify_resource(@id, hash)
        hash.each { |k, v| send "#{k}=", v }
      end

      def modify!
        attrs_to_modify = instance_variables_array(attrs_write)
        return if attrs_to_modify.empty?

        sac.modify_resource(@id, attrs_to_modify)
      end

      def create!
        rep = sac.create_resource(
          @name,
          @password,
          instance_variables_array(attrs_write)
        )
        @id = rep[:Body][:CreateCalendarResourceResponse][:calresource].first[:id]
      end

      def rename!(email)
        sac.rename_resource(@id, email)
        @name = email
      end

      def uploader
        @uploader ||= Upload.new(self)
      end
    end
  end
end
