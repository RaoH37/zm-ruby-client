# frozen_string_literal: true

module Zm
  module Client
    # class for initialize account signature
    class SignatureJsnsInitializer < Base::BaseJsnsInitializer
      def initialize(parent, json)
        super(parent, json)
        @child_class = Signature
      end

      def create
        super

        if @json[:content].is_a?(Array)
          @json[:content].each do |c|
            @item.instance_variable_set(:@txt, c[:_content]) if c[:type] == Signature::TYPE_TXT
            @item.instance_variable_set(:@html, c[:_content]) if c[:type] == Signature::TYPE_HTML
          end
        end

        @item
      end
    end
  end
end
