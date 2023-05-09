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

        soap_request = SoapElement.new(SoapAdminConstants::ADD_ACCOUNT_ALIAS_REQUEST, SoapAdminConstants::NAMESPACE_STR)
        soap_request.add_attributes({ id: @parent.id, alias: email })
        @parent.sac.invoke(soap_request)

        all.push(email)
        true
      end

      def remove!(email)
        return false unless all.include?(Utils.format_email(email))

        soap_request = SoapElement.new(SoapAdminConstants::REMOVE_ACCOUNT_ALIAS_REQUEST, SoapAdminConstants::NAMESPACE_STR)
        soap_request.add_attributes({ id: @parent.id, alias: email })
        @parent.sac.invoke(soap_request)

        all.delete(email)
        true
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
