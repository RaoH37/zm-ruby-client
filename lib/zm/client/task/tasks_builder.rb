# frozen_string_literal: true

module Zm
  module Client
    # class factory [tasks]
    class TasksBuilder < Base::ObjectsBuilder
      def initialize(parent, json)
        @parent = parent
        @json = json
      end

      def make
        root.map do |s|
          Task.new(@parent, s)
        end
      end

      def ids
        root.map { |s| s[:id] }
      end

      def root
        root = @json[:Body][:SearchResponse][:task]
        return [] if root.nil?

        root = [root] unless root.is_a?(Array)
        root
      end
    end
  end
end
