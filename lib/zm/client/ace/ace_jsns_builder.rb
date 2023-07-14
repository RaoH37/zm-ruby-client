# frozen_string_literal: true

module Zm
  module Client
    # class for account ace jsns builder
    class AceJsnsBuilder < Base::BaseJsnsBuilder
      def to_find
        soap_request = SoapElement.account(SoapAccountConstants::GET_RIGHTS_REQUEST)

        soap_request.add_attribute(SoapConstants::ACE, @item.rights.map { |r| { right: r } }) unless @item.rights.empty?

        soap_request
      end

      def to_jsns
        soap_request = SoapElement.account(SoapAccountConstants::GRANT_RIGHTS_REQUEST)
        soap_request.add_attribute(SoapConstants::ACE, attrs)
        soap_request
      end

      def to_delete
        soap_request = SoapElement.account(SoapAccountConstants::REVOKE_RIGHTS_REQUEST)
        soap_request.add_attribute(SoapConstants::ACE, attrs)
        soap_request
      end

      def attrs
        {
          zid: @item.zid,
          gt: @item.gt,
          right: @item.right,
          d: @item.d
        }.reject { |_, v| v.nil? }
      end
    end
  end
end
