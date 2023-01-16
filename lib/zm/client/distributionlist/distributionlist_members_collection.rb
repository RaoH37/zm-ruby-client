# frozen_string_literal: true

module Zm
  module Client
    # Collection Account Aliases
    class DistributionListMembersCollection
      attr_accessor :all

      def initialize(parent)
        @parent = parent
        @all = []
      end

      def add!(emails)
        emails.each { |email| format_email(email) }
        emails.delete_if { |email| @all.include?(email) }
        return false if emails.empty?

        @parent.sac.add_distribution_list_members(@parent.id, emails)
        @all += emails
        true
      end

      def remove!(emails)
        emails.each { |email| format_email(email) }
        emails.delete_if { |email| !@all.include?(email) }
        return false if emails.empty?

        @parent.sac.remove_distribution_list_members(@parent.id, emails)
        @all -= emails
        true
      end

      private

      def format_email(email)
        email.strip!
        email.downcase!
        email
      end
    end
  end
end
