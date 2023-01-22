# frozen_string_literal: true

module Zm
  module Client
    # class for account task
    class Task < Base::AccountObject
      INSTANCE_VARIABLE_KEYS = %i[id uid name l desc start_at dur end_at tn].freeze

      attr_accessor(*INSTANCE_VARIABLE_KEYS)
      attr_writer :folder
      attr_reader :json

      alias description desc
      alias parent_id l

      def initialize(parent, json = nil)
        @parent = parent
        init_from_json(json) if json.is_a?(Hash)
        yield(self) if block_given?
      end

      def concat
        INSTANCE_VARIABLE_KEYS.map { |key| instance_variable_get(arrow_name(key)) }
      end

      def folder
        @folder ||= @parent.folders.all.find { |folder| folder.id == l }
      end

      def download(dest_file_path, fmt = 'ics')
        # @parent.uploader.download_file(folder.absFolderPath, 'ics', ['task'], [id], dest_file_path)
        uploader = Upload.new(@parent, RestAccountConnector.new)
        uploader.download_file(folder.absFolderPath, fmt, ['task'], [id], dest_file_path)
      end

      def create!
        # rep = @parent.sacc.create_task(@parent.token, @l, @name, @view)
        # init_from_json(rep[:Body][:CreateTaskResponse][:task].first)
      end

      def reload!
        # rep = @parent.sacc.get_task(@parent.token, @id)
        # init_from_json(rep[:Body][:GetTaskResponse][:task].first)
      end

      def delete!
        # @parent.sacc.task_action(@parent.token, :delete, @id)
      end

      def init_from_json(json)
        @json = json
        @id = json[:id].to_i
        @uid = json[:uid]
        @tn = json[:tn]
        @name = json[:name]
        @l = json[:l]
        @desc = json[:fr]
        make_date(json)
      end

      def make_date(json)
        return if json[:inst].nil? || json[:inst].first.empty? || json[:dur].nil?

        @start_at = Time.at(json[:inst].first[:s] / 1000)
        @end_at = Time.at((json[:inst].first[:s] + json[:dur]) / 1000)

        return if json[:dur].nil?

        @dur = json[:dur] / 1000
      end
    end
  end
end
