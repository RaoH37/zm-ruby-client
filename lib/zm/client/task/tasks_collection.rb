# frozen_string_literal: true

module Zm
  module Client
    # collection of tasks
    class TasksCollection < Base::AccountSearchObjectsCollection
      def initialize(parent)
        super(parent)
        @child_class = Task
        @builder_class = TasksBuilder
        @type = 'task'
        @sort_by = 'taskDueAsc'
      end
    end
  end
end
