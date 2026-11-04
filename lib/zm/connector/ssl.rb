# frozen_string_literal: true

require 'openssl'

module Zm
  module Connector
    SSL_VERIFY_NONE = { verify: false, verify_hostname: false, verify_mode: OpenSSL::SSL::VERIFY_NONE }.freeze
    SSL_VERIFY_PEER = { verify: true, verify_hostname: true, verify_mode: OpenSSL::SSL::VERIFY_PEER }.freeze
  end
end
