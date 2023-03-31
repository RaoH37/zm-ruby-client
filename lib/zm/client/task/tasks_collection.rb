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

      private

      def query
        return @query unless @query.nil?

        return DEFAULT_QUERY if @folder_ids.empty?

        @folder_ids.map { |id| %(inid:"#{id}") }.join(' OR ')
      end
    end
  end
end
