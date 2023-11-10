# frozen_string_literal: true

module Zm
  module Client
    # objectClass: zimbraDomain
    class Domain < Base::AdminObject
      INSTANCE_VARIABLE_KEYS = %i[name description zimbraDomainName zimbraDomainStatus zimbraId zimbraDomainType
        zimbraDomainDefaultCOSId zimbraGalAccountId zimbraPreAuthKey zimbraGalLdapBindDn zimbraGalLdapBindPassword
        zimbraGalLdapFilter zimbraGalLdapSearchBase zimbraGalLdapURL zimbraGalMode zimbraMailTransport
        zimbraPublicServiceHostname zimbraPublicServiceProtocol zimbraVirtualHostname]

      attr_accessor *INSTANCE_VARIABLE_KEYS

      def initialize(parent)
        super(parent)
        @grantee_type = 'dom'.freeze
      end

      def all_instance_variable_keys
        INSTANCE_VARIABLE_KEYS
      end

      def create!
        attrs_write = INSTANCE_VARIABLE_KEYS.dup
        attrs_write.delete(:name)

        rep = sac.create_domain(
          @name,
          instance_variables_array(attrs_write)
        )
        @id = rep[:Body][:CreateDomainResponse][:domain].first[:id]
      end

      def update!(hash)
        sac.modify_domain(@id, hash)

        hash.each do |k, v|
          arrow_attr_sym = "@#{k}".to_sym

          if v.respond_to?(:empty?) && v.empty?
            self.remove_instance_variable(arrow_attr_sym) if self.instance_variable_get(arrow_attr_sym)
          else
            self.instance_variable_set(arrow_attr_sym, v)
          end
        end
      end

      def modify!
        false
      end

      def accounts
        @accounts ||= DomainAccountsCollection.new(self)
      end

      def delete!
        sac.generic_delete(:DeleteDomainRequest, id)
      end

      def init_from_json(json)
        super(json)
        return unless json[:a].is_a? Array

        n_key = :n
        c_key = :_content
        at_key = '@'

        attrs = {}

        # TODO: definir ici le typage fort des attributs pour ne pas avoir
        # a faire des cases sur les class des attributs dans le code.

        json[:a].each do |a|
          k = "#{at_key}#{a[n_key]}".to_sym
          v = a[c_key]
          if !attrs[k].nil?
            attrs[k] = [attrs[k]] unless attrs[k].is_a?(Array)
            attrs[k].push(v)
          else
            attrs[k] = v
          end
        end

        attrs.each { |k, v| instance_variable_set(k, v) }
      end
    end
  end
end
