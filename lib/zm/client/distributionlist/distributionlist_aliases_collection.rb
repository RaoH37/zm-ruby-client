# frozen_string_literal: true

module Zm
  module Client
    # Collection Account Aliases
    class DistributionListAliasesCollection
      def initialize(parent)
        @parent = parent
        @memorized = []
        build_aliases
      end

      def all
        @memorized
      end

      def add!(email)
        return false if @memorized.include?(format_email(email))

        @parent.sac.add_distribution_list_alias(@parent.id, email)
        @memorized.push(email)
        true
      end

      def remove!(email)
        return false unless @memorized.include?(format_email(email))

        @parent.sac.remove_distribution_list_alias(@parent.id, email)
        @memorized.delete(email)
        true
      end

      private

      def format_email(email)
        email.strip!
        email.downcase!
        email
      end

      def build_aliases
        return if @parent.zimbraMailAlias.nil?

        if @parent.zimbraMailAlias.is_a?(Array)
          @memorized += @parent.zimbraMailAlias
        elsif @parent.zimbraMailAlias.is_a?(String)
          @memorized.push(@parent.zimbraMailAlias)
        end

        @memorized.delete(@parent.name)
      end
    end
  end
end
