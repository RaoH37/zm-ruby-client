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

      def add!(*emails)
        emails.flatten!
        emails.each { |email| Utils.format_email(email) }
        emails.delete_if { |email| @all.include?(email) }
        return false if emails.empty?

        @parent.sac.invoke(build_add(emails))

        @all += emails
        true
      end

      def build_add(emails)
        jsns('addOwners', emails)
      end

      def remove!(*emails)
        emails.flatten!
        emails.each { |email| Utils.format_email(email) }
        emails.delete_if { |email| !@all.include?(email) }
        return false if emails.empty?

        @parent.sac.invoke(build_remove(emails))

        @all -= emails
        true
      end

      def build_remove(emails)
        jsns('removeOwners', emails)
      end

      def jsns(op, emails)
        soap_request = SoapElement.account(SoapAccountConstants::DISTRIBUTION_LIST_ACTION_REQUEST)
        node_dl = SoapElement.create('dl').add_attribute(SoapConstants::BY, SoapConstants::ID).add_content(@parent.id)
        soap_request.add_node(node_dl)
        node_action = SoapElement.create(SoapConstants::ACTION).add_attributes({ op: op, owner: jsns_owners(emails) })
        soap_request.add_node(node_action)
        soap_request
      end

      private

      def jsns_owners(emails)
        emails.map { |email| { by: :name, type: :usr, _content: email } }
      end
    end
  end
end
