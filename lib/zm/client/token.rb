# frozen_string_literal: true

module Zm
  module Client
    class Token
      def initialize(str)
        @str = str
        @key_id, @hmac, @encoded = @str.split('_')
      end

      def to_s
        @str
      end

      def decoded
        @decoded ||= [@encoded].pack('H*')
      end

      def metadatas
        @metadatas ||= Hash[decoded.split(/;/).map { |part| part.split(/=\d+:/) }].freeze
      end

      def zimbra_id
        metadatas['id']
      end

      def admin?
        @admin ||= metadatas['admin'] == '1'
      end

      def server_version
        metadatas['version']
      end

      def expire_at
        @expire_at ||= Time.at(metadatas['exp'].to_f / 1000).freeze
      end

      def expired?
        expire_at < Time.now
      end
    end
  end
end
