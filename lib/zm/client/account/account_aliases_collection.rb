# frozen_string_literal: true

module Zm
  module Client
    # Collection Account Aliases
    class AccountAliasesCollection
      def initialize(parent)
        @parent = parent
        build_aliases
      end

      def all
        @parent.zimbraMailAlias
      end

      def add!(email)
        return false if all.include?(Utils.format_email(email))

        @parent.sac.invoke(build_add(email))

        all.push(email)
        true
      end

      def build_add(email)
        soap_request = SoapElement.admin(SoapAdminConstants::ADD_ACCOUNT_ALIAS_REQUEST)
        soap_request.add_attributes({ id: @parent.id, alias: email })
        soap_request
      end

      def remove!(email)
        return false unless all.include?(Utils.format_email(email))

        @parent.sac.invoke(build_remove(email))

        all.delete(email)
        true
      end

      def build_remove(email)
        soap_request = SoapElement.admin(SoapAdminConstants::REMOVE_ACCOUNT_ALIAS_REQUEST)
        soap_request.add_attributes({ id: @parent.id, alias: email })
        soap_request
      end

      private

      def build_aliases
        return if @parent.zimbraMailAlias.is_a?(Array)

        if @parent.zimbraMailAlias.nil?
          @parent.zimbraMailAlias = []
          return
        end

        @parent.zimbraMailAlias = [@parent.zimbraMailAlias]
      end
    end
  end
end
