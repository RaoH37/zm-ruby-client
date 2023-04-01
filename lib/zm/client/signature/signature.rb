# frozen_string_literal: true

module Zm
  module Client
    # class account signature
    class Signature < Base::AccountObject
      include Zm::Model::AttributeChangeObserver

      TYPE_TXT = 'text/plain'
      TYPE_HTML = 'text/html'

      attr_accessor :id, :name, :txt, :html

      define_changed_attributes :name, :txt, :html

      def create!
        rep = @parent.sacc.jsns_request(:CreateSignatureRequest, @parent.token, jsns_builder.to_jsns,
                                        SoapAccountConnector::ACCOUNTSPACE)
        @id = rep[:Body][:CreateSignatureResponse][:signature].first[:id]
      end

      def modify!
        @parent.sacc.jsns_request(:ModifySignatureRequest, @parent.token, jsns_builder.to_jsns,
                                  SoapAccountConnector::ACCOUNTSPACE)
      end

      def delete!
        return false if @id.nil?

        @parent.sacc.jsns_request(:DeleteSignatureRequest, @parent.token, jsns_builder.to_delete,
                                  SoapAccountConnector::ACCOUNTSPACE)
        @id = nil
      end

      def type
        return TYPE_HTML unless html.nil?

        TYPE_TXT
      end

      def html?
        type == TYPE_HTML
      end

      def txt?
        type == TYPE_TXT
      end

      def content
        html || txt
      end

      private

      def jsns_builder
        @jsns_builder ||= SignatureJsnsBuilder.new(self)
      end
    end
  end
end
