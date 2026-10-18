# frozen_string_literal: true

module Zm
  module Client
    # Collection Messages
    class MessagesCollection < Base::AccountSearchObjectsCollection
      def initialize(parent)
        super
        @child_class = Message
        @builder_class = MessagesBuilder
        @type = SoapRequest::SoapConstants::MESSAGE
        @sort_by = SoapRequest::SoapConstants::DATE_DESC
      end

      def find_each(offset: 0, limit: 500, secure: true, &)
        @more = true
        @offset = offset
        @limit = limit

        while @more
          items = secure ? secure_build_response : build_response
          break if items.nil?

          secure ? secure_each(items, &) : items.each(&)
          @offset += @limit
        end
      end

      private

      def secure_build_response
        build_response
      rescue StandardError => e
        logger.error "Messages search stopped at offset #{@offset}: #{e.message}"
        nil
      end

      def secure_each(items, &)
        items.each(&)
      rescue StandardError => e
        logger.error e.message
      end

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
