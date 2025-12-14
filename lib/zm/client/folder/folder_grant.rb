# frozen_string_literal: true

module Zm
  module Client
    # class for account folder
    class FolderGrant
      GT_USER = 'usr'
      GT_GROUP = 'grp'
      GT_DOMAIN = 'dom'
      GT_PUB = 'pub'
      GT_GUEST = 'guest'
      GT_KEY = 'key'

      attr_reader :parent, :folder_id
      attr_accessor :zid, :gt, :perm, :d, :expiry, :key

      # pour créer un nouveau partage, il faut indiquer zid et/ou d
      # l'attribut gt est obligatoire !
      # l'attribut perm est obligatoire !

      def initialize(parent, zid, gt, perm, d)
        @parent = parent
        @zid = zid
        @gt = gt
        @perm = perm
        @d = d
        @expiry = nil
        @key = nil
        @folder_id = parent.parent.id
      end

      def is_account?
        gt == GT_USER
      end

      def is_dom?
        gt == GT_DOMAIN
      end

      def is_dl?
        gt == GT_GROUP
      end

      def is_public?
        gt == GT_PUBLIC
      end

      def is_external?
        gt == GT_GUEST
      end

      def is_key?
        gt == GT_KEY
      end

      def save!
        @parent.soap_connector.invoke(jsns_builder.to_create)
      end

      def delete!
        @parent.soap_connector.invoke(jsns_builder.to_delete)
        @parent.all.delete(self)
      end

      def to_s
        inspect
      end

      def to_h
        Hash[instance_variables_map]
      end

      def inspect
        keys_str = to_h.map { |k, v| "#{k}: #{v}" }.join(', ')
        "#{self.class}:#{format('0x00%x', (object_id << 1))} #{keys_str}"
      end

      def instance_variables_map
        keys = instance_variables.dup
        keys.delete(:@parent)
        keys.map { |key| [key, instance_variable_get(key)] }
      end

      private

      def jsns_builder
        return @jsns_builder if defined? @jsns_builder

        @jsns_builder = FolderGrantJsnsBuilder.new(self)
      end

      def get_token(target = self)
        token = nil
        return target.token if target.respond_to?(:token) && !target.token.nil?

        token = get_token(target.parent) if target.respond_to?(:parent)

        token
      end
    end
  end
end
