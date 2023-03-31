# frozen_string_literal: true

module Zm
  module Client
    # class account signature
    class Signature < Base::AccountObject
      include Zm::Model::AttributeChangeObserver

      TYPE_TXT = 'text/plain'
      TYPE_HTML = 'text/html'

      INSTANCE_VARIABLE_KEYS = %i[id name txt html]

      attr_reader :id

      define_changed_attributes :name, :txt, :html

      def all_instance_variable_keys
        INSTANCE_VARIABLE_KEYS
      end

      def create!
        rep = @parent.sacc.create_signature(@parent.token, as_jsns)
        @id = rep[:Body][:CreateSignatureResponse][:signature].first[:id]
        super
      end

      def modify!
        @parent.sacc.modify_signature(@parent.token, as_jsns)
        super
      end

      def delete!
        @parent.sacc.delete_signature(@parent.token, jsns_builder.to_delete)
        super
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

      def as_jsns
        jsns_builder.to_jsns
      end
    end
  end
end
