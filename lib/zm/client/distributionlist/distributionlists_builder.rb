# frozen_string_literal: true

module Zm
  module Client
    # class factory [resources]
    class DistributionListsBuilder < Base::ObjectsBuilder
      def make
        return [] if json_items.nil?

        json_items.map do |entry|
          dl = DistributionList.new(@parent)
          dl.init_from_json(entry)
          dl
        end
      end

      private

      def json_items
        @json_items ||= @json[:Body][json_key][:dl]
      end
    end
  end
end
