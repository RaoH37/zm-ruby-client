# frozen_string_literal: true

module Zm
  module Client
    # class account signature
    class Signature < Base::Object
      attr_accessor :id, :name, :txt, :html

      def create!
        rep = @parent.sacc.invoke(jsns_builder.to_jsns)
        @id = rep[:CreateSignatureResponse][:signature].first[:id]
      end

      def modify!
        @parent.sacc.invoke(jsns_builder.to_update)
        true
      end

      def update!(*args)
        raise NotImplementedError
      end

      def rename!(new_name)
        return if new_name == @name

        @parent.sacc.invoke(jsns_builder.to_rename(new_name))
        @name = new_name
      end

      def delete!
        return false if @id.nil?

        @parent.sacc.invoke(jsns_builder.to_delete)
        @id = nil
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
