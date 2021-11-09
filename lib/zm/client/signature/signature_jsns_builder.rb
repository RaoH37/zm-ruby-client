# frozen_string_literal: true

module Zm
  module Client
    # class for account signature
    class SignatureJsnsBuilder

      def initialize(signature)
        @signature = signature
      end

      def to_jsns
        jsns = {
          signature: {
            name: @signature.name,
            content: {
              type: @signature.type,
              _content: @signature.content
            }
          }
        }

        jsns[:signature][:id] = @signature.id unless @signature.id.nil?

        jsns
      end
    end
  end
end