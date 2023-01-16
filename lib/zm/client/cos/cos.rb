# frozen_string_literal: true

module Zm
  module Client
    # objectClass: zimbraCos
    class Cos < Base::AdminObject
      def duplicate(attrs = {})
        # n = clone
        # attrs.each{|k,v| n.instance_variable_set(k, v) }
        # n.id = nil
        # n.zimbraId = nil
        # n
      end

      def update!(hash)
        hash.delete_if { |k, v| v.nil? || !respond_to?(k) }
        return false if hash.empty?

        sac.modify_cos(jsns_builder.to_patch(hash))

        hash.each do |k, v|
          arrow_attr_sym = "@#{k}".to_sym

          if v.respond_to?(:empty?) && v.empty?
            remove_instance_variable(arrow_attr_sym) if instance_variable_get(arrow_attr_sym)
          else
            instance_variable_set(arrow_attr_sym, v)
          end
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
        @servers || servers!
      end

      def servers!
        sc = ServersCollection.new(self)

        @servers = @zimbraMailHostPool.map do |server_id|
          sc.find_by id: server_id
        end
      end

      def accounts
        # todo sélectionner tous les comptes qui ont zimbraCOSID=self.id
      end

      def attrs_write
        @parent.zimbra_attributes.all_cos_attrs_writable_names
      end

      private

      def jsns_builder
        @jsns_builder ||= CosJsnsBuilder.new(self)
      end
    end
  end
end
