module Zm
  module Client
    class ZmError < StandardError
    end

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

    class RestError < StandardError
      def initialize(restbody)
        super(restbody)
      end
    end
  end
end
