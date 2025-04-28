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
        emails.each { |email| Utils.format_email(email) }
        emails.delete_if { |email| @all.include?(email) }
        return false if emails.empty?

        soap_request = SoapElement.admin(SoapAdminConstants::ADD_DISTRIBUTION_LIST_MEMBER_REQUEST)
        soap_request.add_attribute('id', @parent.id)
        node_dlm = SoapElement.create('dlm')
        node_dlm.add_content(emails)
        soap_request.add_node(node_dlm)
        @parent.sac.invoke(soap_request)

        @all += emails
        true
      end

      def remove!(emails)
        emails.each { |email| Utils.format_email(email) }
        emails.delete_if { |email| !@all.include?(email) }
        return false if emails.empty?

        soap_request = SoapElement.admin(SoapAdminConstants::REMOVE_DISTRIBUTION_LIST_MEMBER_REQUEST)
        soap_request.add_attribute('id', @parent.id)
        node_dlm = SoapElement.create('dlm')
        node_dlm.add_content(emails)
        soap_request.add_node(node_dlm)
        @parent.sac.invoke(soap_request)

        @all -= emails
        true
      end
    end
  end
end
