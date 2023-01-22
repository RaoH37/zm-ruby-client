# frozen_string_literal: true

module Zm
  module Client
    # Collection Account Aliases
    class DistributionListOwnersCollection
      attr_accessor :all

      def initialize(parent)
        @parent = parent
        @all = []
      end

      def add!(emails)
        emails.each { |email| format_email(email) }
        emails.delete_if { |email| @all.include?(email) }
        return false if emails.empty?

        @parent.sac.distribution_list_action(@parent.id, :id,
                                             { op: 'addOwners', owner: { by: :name, type: :usr, _content: emails } })
        @all += emails
        true
      end

      def remove!(emails)
        emails.each { |email| format_email(email) }
        emails.delete_if { |email| !@all.include?(email) }
        return false if emails.empty?

        @parent.sac.distribution_list_action(@parent.id, :id,
                                             { op: 'removeOwners', owner: { by: :name, type: :usr, _content: emails } })
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
