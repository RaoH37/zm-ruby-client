# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path('../../lib', __dir__)

require 'minitest/autorun'
require 'yaml'
require 'securerandom'
require 'zm-ruby-client'

module ZmTest
  class IntegrationTest < Minitest::Test
    FIXTURES_PATH = File.expand_path('../fixtures', __dir__)
    CONFIG_PATH = File.join(FIXTURES_PATH, 'config.yml')

    NETWORK_ERRORS = [
      Faraday::ConnectionFailed,
      Faraday::TimeoutError,
      Faraday::SSLError,
      SocketError,
      SystemCallError
    ].freeze

    def before_setup
      super
      skip "integration tests need #{CONFIG_PATH}" unless File.exist?(CONFIG_PATH)
    end

    def capture_exceptions
      super do
        yield
      rescue *NETWORK_ERRORS => e
        skip "Zimbra server unreachable (#{e.class}: #{e.message})"
      end
    end

    def fixture(name)
      YAML.safe_load_file(File.join(FIXTURES_PATH, "#{name}.yml"))
    end

    def unique_name(prefix = 'zmtest')
      "#{prefix}-#{Time.now.strftime('%Y%m%d%H%M%S')}-#{SecureRandom.hex(3)}"
    end
  end
end
