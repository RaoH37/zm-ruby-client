# frozen_string_literal: true

module Zm
  module Client
    # class factory [accounts]
    class MtaQueuesBuilder < Base::ObjectsBuilder
      def make
        records = []
        return records if json_items.nil?

        json_items.each do |entry|
          mta_queue = MtaQueue.new(@parent)
          mta_queue.init_from_json(entry)
          records << mta_queue
        end
        records
      end

      private

      def json_items
        @json_items ||= @json[:Body][json_key][:server].first[:queue]
      end
    end
  end
end
