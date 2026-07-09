# frozen_string_literal: true

module Zm
  module Error
    class SoapError < StandardError
      attr_reader :reason, :code

      def initialize(soapbody)
        @reason = soapbody.dig(:Body, :Fault, :Reason, :Text)
        @code = soapbody.dig(:Body, :Fault, :Detail, :Error, :Code)
        super("[#{@code}] [#{@reason}]")
      end
    end
  end
end
