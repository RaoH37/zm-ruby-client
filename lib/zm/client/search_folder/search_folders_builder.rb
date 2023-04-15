# frozen_string_literal: true

module Zm
  module Client
    # class factory [Search folders]
    class SearchFoldersBuilder < Base::ObjectsBuilder
      def initialize(parent, json)
        super(parent, json)
        @json_item_key = :search
      end

      def make
        return [] if json_items.nil?

        json_items.map do |entry|
          SearchFolderJsnsInitializer.create(@parent, entry)
        end
      end
    end
  end
end
