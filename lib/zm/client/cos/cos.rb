# frozen_string_literal: true

module Zm
  module Client
    # objectClass: zimbraCos
    class Cos < Base::Object
      include HasSoapAdminConnector

      def modify!
        sac.invoke(build_modify)
        true
      end

      def build_modify
        jsns_builder.to_update
      end

      def update!(hash)
        return false if hash.delete_if { |k, v| v.nil? || !respond_to?(k) }.empty?

        do_update!(hash)

        hash.each do |key, value|
          update_attribute(key, value)
        end

        true
      end

      def create!
        resp = sac.invoke(build_create)

        @id = resp[:CreateCosResponse][:cos].first[:id]
      end

      def build_create
        jsns_builder.to_create
      end

      def delete!
        sac.invoke(build_delete)
      end

      def build_delete
        jsns_builder.to_delete
      end

      def clone!(new_name)
        resp = sac.invoke(build_clone(new_name))
        resp[:CopyCosResponse][:cos].first[:id]
      end

      def build_clone(new_name)
        jsns_builder.to_copy(new_name)
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

      def jsns_builder
        @jsns_builder ||= CosJsnsBuilder.new(self)
      end

      private

      def do_update!(hash)
        sac.invoke(jsns_builder.to_patch(hash))
      end
    end
  end
end
