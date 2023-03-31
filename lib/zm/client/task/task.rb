# frozen_string_literal: true

module Zm
  module Client
    # class for account task
    class Task < Base::AccountObject
      attr_accessor :uid, :priority, :ptst, :percentComplete, :name, :loc, :alarm, :isOrg, :id, :invId, :compNum, :l,
                    :status, :class, :allDay, :f, :tn, :t, :rev, :s, :d, :md, :ms, :cm, :sf

      alias folder_id l

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
        raise NotImplementedError
      end

      def reload!
        # rep = @parent.sacc.get_task(@parent.token, @id)
        # init_from_json(rep[:Body][:GetTaskResponse][:task].first)
        raise NotImplementedError
      end

      def delete!
        # @parent.sacc.task_action(@parent.token, :delete, @id)
        raise NotImplementedError
      end
    end
  end
end
