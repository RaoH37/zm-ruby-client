# frozen_string_literal: true

module Zm
  module Client
    # class for account folder
    class FolderGrant
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

      def to_h
        h = Hash[instance_variables.reject { |iv| iv == :@parent }.map { |iv| [iv, instance_variable_get(iv)] }]
        h.merge!({ :@parent => @parent.class })
        h
      end

      def is_account?
        gt == 'usr'
      end

      def is_dom?
        gt == 'dom'
      end

      def is_dl?
        gt == 'grp'
      end

      def is_public?
        gt == 'pub'
      end

      def is_external?
        gt == 'guest'
      end

      def is_key?
        gt == 'key'
      end

      def save!
        @parent.sacc.folder_action(get_token, jsns_builder.to_create)
      end

      def delete!
        @parent.sacc.folder_action(get_token, jsns_builder.to_delete)
        @parent.all.delete(self)
      end

      private

      def jsns_builder
        @jsns_builder ||= FolderGrantJsnsBuilder.new(self)
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
