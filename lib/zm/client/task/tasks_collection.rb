# frozen_string_literal: true

module Zm
  module Client
    # collection of tasks
    class TasksCollection < Base::AccountSearchObjectsCollection
      DEFAULT_QUERY = 'in:tasks'

      def initialize(parent)
        super(parent)
        @child_class = Task
        @builder_class = TasksBuilder
        @type = 'task'
        @sort_by = 'taskDueAsc'
      end

      def find_each
        @all = []
        (1970..(Time.now.year + 10)).each do |year|
          @start_at = Time.new(year, 1, 1)
          @end_at = Time.new(year, 12, 31)
          @more = true
          @offset = 0
          @limit = 500

          while @more
            @all += build_response
            @offset += @limit
          end
        end
        @all
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
