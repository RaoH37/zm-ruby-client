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

      def find_each(offset: 0, limit: 500, secure: true, &block)
        @more = true
        @offset = offset
        @limit = limit

        if secure
          while @more
            begin
              build_response.each { |item| block.call(item) }
            rescue StandardError => e
              logger.error e.message
            end

            @offset += @limit
          end
        else
          while @more
            build_response.each { |item| block.call(item) }
            @offset += @limit
          end
        end
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
