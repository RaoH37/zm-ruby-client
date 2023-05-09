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

        # @parent.sac.add_distribution_list_alias(@parent.id, email)

        soap_request = SoapElement.admin(SoapAdminConstants::ADD_DISTRIBUTION_LIST_ALIAS_REQUEST)
        soap_request.add_attributes({ id: @parent.id, alias: email })
        @parent.sac.invoke(soap_request)

        @all.push(email)
        true
      end

      def remove!(email)
        return false unless @all.include?(Utils.format_email(email))

        soap_request = SoapElement.admin(SoapAdminConstants::REMOVE_DISTRIBUTION_LIST_ALIAS_REQUEST)
        soap_request.add_attributes({ id: @parent.id, alias: email })
        @parent.sac.invoke(soap_request)

        @all.delete(email)
        true
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
