# frozen_string_literal: true

module Zm
  module Client
    # Collection Account Aliases
    class DistributionListAliasesCollection
      def initialize(parent)
        @parent = parent
        @all = []
        build_aliases
      end

      attr_reader :all

      def add!(email)
        return false if @all.include?(Utils.format_email(email))

        @parent.sac.add_distribution_list_alias(@parent.id, email)
        @all.push(email)
        true
      end

      def remove!(email)
        return false unless @all.include?(Utils.format_email(email))

        @parent.sac.remove_distribution_list_alias(@parent.id, email)
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
