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


        @parent.sac.invoke(build_add(emails))

        @all += emails
        true
      end

      def build_add(emails)
        soap_request = SoapElement.admin(SoapAdminConstants::ADD_DISTRIBUTION_LIST_MEMBER_REQUEST)
        soap_request.add_attribute(SoapConstants::ID, @parent.id)
        node_dlm = SoapElement.create(SoapConstants::DLM)
        node_dlm.add_content(emails)
        soap_request.add_node(node_dlm)
        soap_request
      end

      def remove!(emails)
        emails.each { |email| Utils.format_email(email) }
        emails.delete_if { |email| !@all.include?(email) }
        return false if emails.empty?


        @parent.sac.invoke(build_remove(emails))

        @all -= emails
        true
      end

      def build_remove(emails)
        soap_request = SoapElement.admin(SoapAdminConstants::REMOVE_DISTRIBUTION_LIST_MEMBER_REQUEST)
        soap_request.add_attribute(SoapConstants::ID, @parent.id)
        node_dlm = SoapElement.create(SoapConstants::DLM)
        node_dlm.add_content(emails)
        soap_request.add_node(node_dlm)
        soap_request
      end
    end
  end
end
