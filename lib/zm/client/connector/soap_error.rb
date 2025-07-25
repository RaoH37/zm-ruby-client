# frozen_string_literal: true

module Zm
  module Client
    class ZmError < StandardError
    end

    class SoapError < StandardError
      attr_reader :reason, :code

      def initialize(soapbody)
        if soapbody.start_with?('{')
          init_from_json(soapbody)
        elsif soapbody.start_with?('<')
          init_from_xml(soapbody)
        end

        super "[#{@code}] [#{@reason}]"
      end

      private

      def init_from_json(soapbody)
        json = JSON.parse(soapbody, symbolize_names: true)
        @reason = json[:Body][:Fault][:Reason][:Text]
        @code = json[:Body][:Fault][:Detail][:Error][:Code]
      end

      def init_from_xml(soapbody)
        code_match = soapbody.match(%r{<Code>(.*?)</Code>})
        @code = code_match[1]

        text_match = soapbody.match(%r{<soap:Reason>.*?<soap:Text>(.*?)</soap:Text>}m)
        @reason = text_match[1]
      end
    end

    class AuthError < SoapError
    end

    class RestError < StandardError
    end
  end
end
