# frozen_string_literal: true

module Zm
  module Client
    # objectClass: zimbraDomain
    class Domain < Base::AdminObject
      INSTANCE_VARIABLE_KEYS = %i[name description zimbraDomainName zimbraDomainStatus zimbraId zimbraDomainType
        zimbraDomainDefaultCOSId zimbraGalAccountId zimbraPreAuthKey zimbraGalLdapBindDn zimbraGalLdapBindPassword
        zimbraGalLdapFilter zimbraGalLdapSearchBase zimbraGalLdapURL zimbraGalMode zimbraMailTransport]

      attr_accessor *INSTANCE_VARIABLE_KEYS

      def initialize(parent)
        super(parent)
        @grantee_type = 'dom'.freeze
      end

      # def to_h
      #   hashmap = Hash[all_instance_variable_keys.map { |key| [key, instance_variable_get(arrow_name(key))] }]
      #   hashmap.delete_if { |_, v| v.nil? }
      #   hashmap
      # end

      # def all_instance_variable_keys
      #   INSTANCE_VARIABLE_KEYS
      # end

      def create!
        rep = sac.create_domain(jsns_builder.to_jsns)
        @id = rep[:Body][:CreateDomainResponse][:domain].first[:id]
      end

      def update!(hash)
        hash.delete_if { |k, v| v.nil? || !respond_to?(k) }
        return false if hash.empty?

        sac.modify_domain(jsns_builder.to_patch(hash))

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
        sac.modify_domain(jsns_builder.to_update)
        true
      end

      def delete!
        sac.delete_domain(@id)
        true
      end

      def accounts
        @accounts ||= DomainAccountsCollection.new(self)
      end

      # def account_quotas(server_id)
      #   rep = sac.get_quota_usage(name, nil, nil, nil, nil, nil, nil, server_id)
      #   AccountsBuilder.new(@parent, rep).make
      # end

      # def init_from_json(json)
      #   super(json)
      #   return unless json[:a].is_a? Array
      #
      #   n_key = :n
      #   c_key = :_content
      #   at_key = '@'
      #
      #   attrs = {}
      #
      #   # TODO: definir ici le typage fort des attributs pour ne pas avoir
      #   # a faire des cases sur les class des attributs dans le code.
      #
      #   json[:a].each do |a|
      #     k = "#{at_key}#{a[n_key]}".to_sym
      #     v = a[c_key]
      #     if !attrs[k].nil?
      #       attrs[k] = [attrs[k]] unless attrs[k].is_a?(Array)
      #       attrs[k].push(v)
      #     else
      #       attrs[k] = v
      #     end
      #   end
      #
      #   attrs.each { |k, v| instance_variable_set(k, v) }
      # end

      def attrs_write
        @parent.zimbra_attributes.all_domain_attrs_writable_names
      end

      private

      def jsns_builder
        @jsns_builder ||= DomainJsnsBuilder.new(self)
      end
    end
  end
end
