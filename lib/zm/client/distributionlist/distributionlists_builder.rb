# frozen_string_literal: true

module Zm
  module Client
    # class factory [resources]
    class DistributionListsBuilder < Base::ObjectsBuilder
      def make
        return [] if json_items.nil?

        json_items.map do |entry|
          dl = DistributionList.new
          dl.init_from_json(entry)
        end
      end

      private

      def json_items
        @json_items ||= @json[:Body][json_key][:dl]
      end
    end
  end
end
