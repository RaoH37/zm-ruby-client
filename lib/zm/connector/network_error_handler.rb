# frozen_string_literal: true

module Zm
  module Connector
    # convert Faraday network errors into Zm::Error::ConnectionError, the original error is kept as cause
    module NetworkErrorHandler
      NETWORK_ERRORS = [Faraday::ConnectionFailed, Faraday::TimeoutError, Faraday::SSLError].freeze

      private

      def handle_network_errors
        yield
      rescue *NETWORK_ERRORS => e
        raise Zm::Error::ConnectionError, "#{e.class}: #{e.message}"
      end
    end
  end
end
