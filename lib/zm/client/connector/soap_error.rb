module Zm
  module Client
    class SoapError < StandardError
      attr_reader :reason, :code
      def initialize(soapbody)
        @reason = soapbody[:Body][:Fault][:Reason][:Text]
        @code = soapbody[:Body][:Fault][:Detail][:Error][:Code]
        super "[#{@code}] [#{@reason}]"
      end
    end

    class AuthError < SoapError
    end
  end
end
