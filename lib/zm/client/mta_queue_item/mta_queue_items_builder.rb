# frozen_string_literal: true

module Zm
  module Client
    # class factory [MtaQueueItem]
    class MtaQueueItemsBuilder < Base::ObjectsBuilder
      def make
        return [] if json_items.nil?

        json_items.map do |entry|
          MtaQueueItemJsnsInitializer.create(@parent, entry)
        end
      end

      private

      def json_items
        @json_items ||= @json[:Body][json_key][:server].first[:queue].first[:qi]
      end
    end
  end
end
