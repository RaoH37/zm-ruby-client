# frozen_string_literal: true

module Zm
  module Client
    # Collection Account Aliases
    class DistributionListAliasesCollection
      include MissingMethodStaticCollection

      def initialize(parent)
        @parent = parent
        @all = []
        build_aliases
      end

      def add!(email)
        return false if @all.include?(Utils.format_email(email))

        # soap_request = SoapElement.admin(SoapAdminConstants::ADD_DISTRIBUTION_LIST_ALIAS_REQUEST)
        # soap_request.add_attributes({ id: @parent.id, alias: email })
        @parent.sac.invoke(build_add(email))

        @all.push(email)
        true
      end

      def build_add(email)
        soap_request = SoapElement.admin(SoapAdminConstants::ADD_DISTRIBUTION_LIST_ALIAS_REQUEST)
        soap_request.add_attributes({ id: @parent.id, alias: email })
        soap_request
      end

      def remove!(email)
        return false unless @all.include?(Utils.format_email(email))

        # soap_request = SoapElement.admin(SoapAdminConstants::REMOVE_DISTRIBUTION_LIST_ALIAS_REQUEST)
        # soap_request.add_attributes({ id: @parent.id, alias: email })
        @parent.sac.invoke(build_remove(email))

        @all.delete(email)
        true
      end

      def build_remove(email)
        soap_request = SoapElement.admin(SoapAdminConstants::REMOVE_DISTRIBUTION_LIST_ALIAS_REQUEST)
        soap_request.add_attributes({ id: @parent.id, alias: email })
        soap_request
      end

      private

      def build_aliases
        return if @parent.zimbraMailAlias.nil?

        case @parent.zimbraMailAlias
        when Array
          @all += @parent.zimbraMailAlias
        when String
          @all.push(@parent.zimbraMailAlias)
        end

        @all.delete(@parent.name)
      end
    end
  end
end
