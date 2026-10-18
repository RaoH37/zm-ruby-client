# frozen_string_literal: true

module Zm
  module SoapRequest
    class SoapContext
      def initialize
        @token = nil
        @user_agent = 'zmsoap'
        @target_server = nil
        @account = nil
      end

      def initialize_copy(source)
        super
        @source = source
        @token = nil
      end

      def token(str)
        @token = str
        self
      end

      def auth_token
        @token || @source&.auth_token
      end

      def user_agent(str)
        @user_agent = str
        self
      end

      def target_server(str)
        @target_server = str
        self
      end

      def account(by, value)
        @account = { by:, _content: value }
        self
      end

      def to_hash
        h = {
          authToken: auth_token,
          userAgent: { name: @user_agent },
          account: @account,
          targetServer: @target_server
        }
        h.compact!
        h
      end
    end
  end
end
