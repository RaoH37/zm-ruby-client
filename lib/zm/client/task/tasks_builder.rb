# frozen_string_literal: true

module Zm
  module Client
    # class factory [tasks]
    class TasksBuilder < Base::ObjectsBuilder
      def initialize(parent, json)
        super(parent, json)
        @json_item_key = :task
      end

      def make
        return [] if json_items.nil?

        json_items.map do |entry|
          TaskJsnsInitializer.create(@parent, entry)
        end
      end
    end
  end
end
