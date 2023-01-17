# frozen_string_literal: true

module Zm
  module Client
    # objectClass: zimbraDomain
    class Domain < Base::AdminObject
      def initialize(parent)
        super(parent)
        @grantee_type = 'dom'.freeze
      end

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
