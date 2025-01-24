# frozen_string_literal: true

module Zm
  module Client
    # class account signature
    class Signature < Base::Object
      include RequestMethodsMailbox

      attr_accessor :id, :name, :txt, :html

      def create!
        rep = @parent.sacc.invoke(build_create)
        @id = rep[:CreateSignatureResponse][:signature].first[:id]
      end

      def update!(*args)
        raise NotImplementedError
      end

      def type
        return ContentType::HTML unless html.nil?

        ContentType::TEXT
      end

      def html?
        type == ContentType::HTML
      end

      def txt?
        type == ContentType::TEXT
      end

      def content
        html || txt || ''
      end

      private

      def jsns_builder
        @jsns_builder ||= SignatureJsnsBuilder.new(self)
      end
    end
  end
end
