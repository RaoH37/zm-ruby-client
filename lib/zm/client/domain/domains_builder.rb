# frozen_string_literal: true

module Zm
  module Client
    # Class Builder [Domain]
    class DomainsBuilder < Base::ObjectsBuilder
      def make
        records = []
        return records if json_items.nil?

        json_items.each do |entry|
          domain = Domain.new(@parent)
          domain.init_from_json(entry)
          records << domain
        end

        records
      end

      private

      def json_items
        @json_items ||= @json[:Body][json_key][:domain]
      end
    end
  end
end
