# frozen_string_literal: true

module Zm
  module Client
    # class account signature
    class Signature < Base::Object
      include SoapRequest::RequestMethodsMailbox
      extend Relationship
      has_jsns_builder

      attr_accessor :id, :name, :txt, :html

      def create!
        rep = @parent.soap_connector.invoke(build_create)
        @id = rep[:CreateSignatureResponse][:signature].first[:id]
      end

      def update!(*args)
        raise NotImplementedError
      end

      def type
        return Zm::Utils::ContentType::HTML unless html.nil?

        Zm::Utils::ContentType::TEXT
      end

      def html?
        type == Zm::Utils::ContentType::HTML
      end

      def txt?
        type == Zm::Utils::ContentType::TEXT
      end

      def content
        html || txt || ''
      end
    end
  end
end
