# frozen_string_literal: true

module Zm
  module Client
    # class for account signature jsns builder
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

      def to_delete
        { signature: { id: @signature.id } }
      end
    end
  end
end
