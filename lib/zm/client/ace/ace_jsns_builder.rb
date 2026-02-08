# frozen_string_literal: true

module Zm
  module Client
    # class for account ace jsns builder
    class AceJsnsBuilder < Base::BaseJsnsBuilder
      def to_find
        soap_request = SoapRequest::SoapElement.account(Zm::SoapRequest::SoapAccountConstants::GET_RIGHTS_REQUEST)

        soap_request.add_attribute(SoapRequest::SoapConstants::ACE, @item.rights.map { |r| { right: r } }) unless @item.rights.empty?

        soap_request
      end

      def to_jsns
        SoapRequest::SoapElement.account(Zm::SoapRequest::SoapAccountConstants::GRANT_RIGHTS_REQUEST)
                   .add_attribute(SoapRequest::SoapConstants::ACE, attrs)
      end

      def to_delete
        SoapRequest::SoapElement.account(Zm::SoapRequest::SoapAccountConstants::REVOKE_RIGHTS_REQUEST)
                   .add_attribute(SoapRequest::SoapConstants::ACE, attrs)
      end

      def attrs
        h = {
          zid: @item.zid,
          gt: @item.gt,
          right: @item.right,
          d: @item.d
        }
        h.compact!
        h
      end
    end
  end
end
