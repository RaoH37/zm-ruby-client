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
        return @decoded if defined? @decoded

        @decoded = [@encoded].pack('H*')
      end

      def metadatas
        return @metadatas if defined? @metadatas

        @metadatas = decoded.split(';').each_with_object({}) do |part, h|
          key, value = part.split(/=\d+:/, 2)
          h[key] = value
        end.freeze
      end

      def zimbra_id
        metadatas['id']
      end

      def admin?
        return @admin if defined? @admin

        @admin = metadatas['admin'] == '1'
      end

      def server_version
        metadatas['version']
      end

      def expire_at
        return @expire_at if defined? @expire_at

        @expire_at = Time.at(metadatas['exp'].to_f / 1000).freeze
      end

      def expired?
        expire_at < Time.now
      end
    end
  end
end
