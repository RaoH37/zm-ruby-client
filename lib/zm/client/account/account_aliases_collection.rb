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
        return false if all.include?(format_email(email))

        @parent.sac.add_account_alias(@parent.id, email)
        all.push(email)
        true
      end

      def remove!(email)
        return false unless all.include?(format_email(email))

        @parent.sac.remove_account_alias(@parent.id, email)
        all.delete(email)
        true
      end

      private

      def format_email(email)
        email.strip!
        email.downcase!
        email
      end

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
