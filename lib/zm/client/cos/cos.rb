# frozen_string_literal: true

module Zm
  module Client
    # objectClass: zimbraCos
    class Cos < Base::AdminObject
      def update!(hash)
        return false if hash.delete_if { |k, v| v.nil? || !respond_to?(k) }.empty?

        sac.modify_cos(jsns_builder.to_patch(hash))

        hash.each do |key, value|
          update_attribute(key, value)
        end

        true
      end

      def modify!
        sac.modify_cos(jsns_builder.to_update)
        true
      end

      def create!
        rep = sac.create_cos(jsns_builder.to_jsns)
        @id = rep[:Body][:CreateCosResponse][:cos].first[:id]
      end

      def servers
        @servers ||= CosServersCollection.new(self)
      end

      def domains
        return if @id.nil?

        @domains ||= CosDomainsCollection.new(self)
      end

      def accounts
        return if @id.nil?

        @accounts ||= CosAccountsCollection.new(self)
      end

      def attrs_write
        @parent.zimbra_attributes.all_cos_attrs_writable_names
      end

      private

      def jsns_builder
        @jsns_builder ||= CosJsnsBuilder.new(self)
      end

      def update_attribute(key, value)
        arrow_attr_sym = Utils.arrow_name_sym(key)

        if value.respond_to?(:empty?) && value.empty?
          remove_instance_variable(arrow_attr_sym) if instance_variable_get(arrow_attr_sym)
        else
          instance_variable_set(arrow_attr_sym, value)
        end
      end
    end
  end
end
