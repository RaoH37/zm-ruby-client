# frozen_string_literal: true

module Zm
  module Client
    # class factory [MtaQueueItem]
    class MtaQueueItemsBuilder < Base::ObjectsBuilder
      def make
        records = []
        return records if json_items.nil?

        json_items.each do |entry|
          mta_queue = MtaQueueItem.new(@parent)
          mta_queue.init_from_json(entry)
          records << mta_queue
        end
        records
      end

      private

      def json_items
        # puts @json
        @json_items ||= @json[:Body][json_key][:server].first[:queue].first[:qi]
      end
    end
  end
end
