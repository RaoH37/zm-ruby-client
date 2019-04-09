require 'zm/modules/common/resource_common'

module Zm
  module Client
    # objectClass: zimbraCalendarResource
    class Resource < Base::Object

      attr_reader :name, :id
      
      def initialize(parent)
        self.extend(ResourceCommon)
        super(parent)
      end

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
    end
  end
end
