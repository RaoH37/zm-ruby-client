# frozen_string_literal: true

module Zm
  module Client
    # class account ace
    class Ace < Base::Object
      attr_accessor :zid, :gt, :right, :d

      def create!
        rep = @parent.sacc.grant_rights(@arent.token, jsns_builder.to_jsns)
        json = rep[:Body][:GrantRightsResponse][:ace].first if rep[:Body][:GrantRightsResponse][:ace].is_a?(Array)
        AceJsnsInitializer.update(self, json) unless json.nil?
        true
      end

      def delete!
        @parent.sacc.revoke_rights(@arent.token, jsns_builder.to_delete)
        @parent.all.delete(self)
        true
      end

      private

      def jsns_builder
        @jsns_builder ||= AceJsnsBuilder.new(self)
      end

      # def get_token(target = self)
      #   token = nil
      #   return target.token if target.respond_to?(:token) && !target.token.nil?
      #
      #   token = get_token(target.parent) if target.respond_to?(:parent)
      #
      #   token
      # end
    end
  end
end
