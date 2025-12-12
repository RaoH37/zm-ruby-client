# frozen_string_literal: true

module Zm
  module Client
    class ZmError < StandardError
    end

    class SoapError < StandardError
      attr_reader :reason, :code

      def initialize(soapbody)
        @reason = soapbody.dig(:Body, :Fault, :Reason, :Text)
        @code = soapbody.dig(:Body, :Fault, :Detail, :Error, :Code)
        super "[#{@code}] [#{@reason}]"
      end
    end

    class AuthError < SoapError
    end

    class RestError < StandardError
    end
  end
end
