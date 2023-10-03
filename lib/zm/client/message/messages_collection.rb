# frozen_string_literal: true

module Zm
  module Client
    # Collection Messages
    class MessagesCollection < Base::AccountSearchObjectsCollection
      def initialize(parent)
        super(parent)
        @child_class = Message
        @builder_class = MessagesBuilder
        @type = SoapConstants::MESSAGE
        @sort_by = SoapConstants::DATE_DESC
      end

      private

      def build_options
        options = super
        options[:recip] = @recip
        options
      end

      def reset_query_params
        super
        @recip = 2
      end
    end
  end
end
