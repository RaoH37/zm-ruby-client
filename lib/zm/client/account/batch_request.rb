# frozen_string_literal: true

module Zm
  module Client
    class Account
      class BatchRequest
        ONERRORS = Set['continue', 'stop'].freeze

        attr_reader :requests

        def initialize(account)
          @account = account
          @requests = []
        end

        def invoke(onerror: 'continue')
          return [] if @requests.empty?

          onerror = ONERRORS.first unless ONERRORS.include?(onerror)

          soap_resp = @account.soap_account_connector.invoke(build(onerror))[:BatchResponse]
          @requests.clear
          format_response(soap_resp)
        end

        private

        def build(onerror)
          soap_request = SoapElement.new(SoapConstants::BATCH_REQUEST, SoapConstants::NAMESPACE_STR)
                                    .add_attribute(:onerror, onerror)

          @requests.each_with_index do |request, index|
            request.add_attribute(:requestId, index + 1)
            soap_request.add_node(request)
          end

          soap_request
        end

        def format_response(soap_resp)
          soap_resp.delete(:_jsns)
          responses = soap_resp.values.flatten
          responses.each do |response|
            response[:requestId] = response[:requestId].to_i
          end
          responses
        end
      end
    end
  end
end
