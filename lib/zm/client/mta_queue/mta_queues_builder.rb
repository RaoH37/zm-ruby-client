# frozen_string_literal: true

module Zm
  module Client
    # class factory [MtaQueue]
    class MtaQueuesBuilder < Base::ObjectsBuilder
      def make
        return [] if json_items.nil?

        json_items.map do |entry|
          MtaQueueJsnsInitializer.create(@parent, entry)
        end
      end

      private

      def json_items
        @json_items ||= @json[:GetMailQueueInfoResponse][:server].first[:queue]
      end
    end
  end
end
