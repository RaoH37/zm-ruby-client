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

        @parent.sac.invoke(jsns('addOwners', emails))

        @all += emails
        true
      end

      def remove!(*emails)
        emails.flatten!
        emails.each { |email| Utils.format_email(email) }
        emails.delete_if { |email| !@all.include?(email) }
        return false if emails.empty?

        @parent.sac.invoke(jsns('removeOwners', emails))

        @all -= emails
        true
      end

      private

      def jsns(op, emails)
        soap_request = SoapElement.account(SoapAccountConstants::DISTRIBUTION_LIST_ACTION_REQUEST)
        node_dl = SoapElement.create('dl').add_attribute(SoapConstants::BY, SoapConstants::ID).add_content(@parent.id)
        soap_request.add_node(node_dl)
        node_action = SoapElement.create(SoapConstants::ACTION).add_attributes({ op: op, owner: jsns_owners(emails) })
        soap_request.add_node(node_action)
        soap_request
      end

      def jsns_owners(emails)
        emails.map { |email| { by: :name, type: :usr, _content: email } }
      end
    end
  end
end
