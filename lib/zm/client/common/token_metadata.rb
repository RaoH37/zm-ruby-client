# frozen_string_literal: true

module Zm
  module Client
    class TokenMetaDataError < StandardError; end

    class TokenMetaData
      def initialize(token)
        raise TokenMetaDataError, 'no such token' unless token.is_a?(String)

        parts = token.split('_')
        raise TokenMetaDataError, 'invalid token' unless parts.length == 3

        @key_id = parts[0]
        @hmac = parts[1]
        @encoded = parts[2]
      end

      def decoded
        @decoded ||= [@encoded].pack('H*')
      end

      def metadatas
        @metadatas ||= Hash[decoded.split('
').map do |v|
  key, len, str = v.split(/[:=]/)
  [key, str]
end].freeze
      end

      def zimbra_id
        metadatas['id']
      end

      def is_admin?
        @is_admin ||= metadatas['admin'] == '1'
      end

      def server_version
        metadatas['version']
      end

      def expire_at
        @expire_at ||= Time.at(metadatas['exp'].to_f / 1000).freeze
      end
    end
  end
end
