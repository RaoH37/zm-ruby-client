# frozen_string_literal: true

module Zm
  module Client
    # class factory [datasources]
    class DataSourceBuilder < Base::ObjectsBuilder
      def make
        return [] if json_items.nil?

        json_items.slice(*DataSource::TYPES).flat_map do |data_source_type, entries|
          entries.map do |entry|
            DataSourceJsnsInitializer.create(@parent, data_source_type, entry)
          end
        end
      end

      private

      def json_items
        return @json_items if defined? @json_items

        @json_items = @json[json_key]
      end
    end
  end
end
