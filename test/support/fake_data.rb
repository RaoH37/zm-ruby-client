# frozen_string_literal: true

require 'securerandom'

module ZmTest
  module FakeData
    module_function

    def token(id: SecureRandom.uuid, admin: true, expires_in: 3600)
      exp = ((Time.now.to_f + expires_in) * 1000).to_i.to_s
      metadatas = { 'id' => id, 'exp' => exp, 'admin' => admin ? '1' : '0', 'version' => '10.1.0' }
      encoded = metadatas.map { |k, v| "#{k}=#{v.length}:#{v}" }.join(';').unpack1('H*')
      "0_#{SecureRandom.hex(20)}_#{encoded}"
    end

    def auth_response(auth_token = token)
      { AuthResponse: { authToken: [{ _content: auth_token }], lifetime: 3_600_000 } }
    end

    def attrs(hash)
      hash.flat_map do |name, value|
        Array(value).map { |v| { n: name.to_s, _content: v } }
      end
    end

    def account(name:, id: SecureRandom.uuid, **attributes)
      { name:, id:, a: attrs(attributes) }
    end
  end
end
