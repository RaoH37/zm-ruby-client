# frozen_string_literal: true

module Zm
  module Client
    # class account signature
    class Signature < Base::Object
      attr_accessor :id, :name, :txt, :html

      def create!
        rep = @parent.sacc.invoke(build_create)
        @id = rep[:CreateSignatureResponse][:signature].first[:id]
      end

      def build_create
        jsns_builder.to_jsns
      end

      def modify!
        @parent.sacc.invoke(build_modify)
        true
      end

      def build_modify
        jsns_builder.to_update
      end

      def update!(*args)
        raise NotImplementedError
      end

      def rename!(new_name)
        return if new_name == @name

        @parent.sacc.invoke(build_rename(new_name))
        @name = new_name
      end

      def build_rename(new_name)
        jsns_builder.to_rename(new_name)
      end

      def delete!
        return false if @id.nil?

        @parent.sacc.invoke(build_delete)
        @id = nil
      end

      def build_delete
        jsns_builder.to_delete
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
