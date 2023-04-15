# frozen_string_literal: true

module Zm
  module Client
    # class for account task
    class Task < Base::Object
      include BelongsToFolder
      include BelongsToTag

      attr_accessor :uid, :priority, :ptst, :percentComplete, :name, :loc, :alarm, :isOrg, :id, :invId, :compNum, :l,
                    :status, :class, :allDay, :f, :tn, :t, :rev, :s, :d, :md, :ms, :cm, :sf

      def download(dest_file_path, fmt = 'ics')
        uploader = Upload.new(@parent, RestAccountConnector.new)
        uploader.download_file(folder.absFolderPath, fmt, ['task'], [id], dest_file_path)
      end

      def create!
        raise NotImplementedError
      end

      def modify!
        raise NotImplementedError
      end

      def update!(*args)
        raise NotImplementedError
      end

      def rename!(*args)
        raise NotImplementedError
      end

      def reload!
        raise NotImplementedError
      end

      def delete!
        raise NotImplementedError
      end
    end
  end
end
