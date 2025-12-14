# frozen_string_literal: true

module Zm
  module Client
    # collection of tasks
    class TasksCollection < Base::AccountSearchObjectsCollection
      DEFAULT_QUERY = 'in:tasks'

      def initialize(parent)
        super
        @child_class = Task
        @builder_class = TasksBuilder
        @type = 'task'
        @sort_by = 'taskDueAsc'
      end

      def find_each(offset: 0, limit: 500, &block)
        (Time.at(0).year..(Time.now.year + 10)).each do |year|
          @start_at = Time.new(year, 1, 1)
          @end_at = Time.new(year, 12, 31)
          @more = true
          @offset = offset
          @limit = limit

          while @more
            build_response.each { |item| block.call(item) }
            @offset += @limit
          end
        end
      end

      private

      def query
        return @query unless @query.nil?

        return DEFAULT_QUERY if @folder_ids.empty?

        @folder_ids.map { |id| %(inid:"#{id}") }.join(' OR ')
      end
    end
  end
end
