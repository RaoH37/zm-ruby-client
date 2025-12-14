# frozen_string_literal: true

module Zm
  module Client
    # class factory [datasources]
    class DataSourceBuilder < Base::ObjectsBuilder
      def make
        return [] if json_items.nil?

        ds = []
        json_items.each do |data_source_type, entries|
          next unless DataSource::TYPES.include?(data_source_type)

          entries.each do |entry|
            ds << DataSourceJsnsInitializer.create(@parent, data_source_type, entry)
          end
        end

        ds
      end

      private

      def json_items
        return @json_items if defined? @json_items

        @json_items = @json[json_key]
      end
    end
  end
end
