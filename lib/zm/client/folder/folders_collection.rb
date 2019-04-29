module Zm
  module Client
    class FoldersCollection < Base::ObjectsCollection
      METHODS_MISSING_LIST = %i[select each map length].to_set.freeze

      def initialize(parent)
        @parent = parent
      end

      def new
        folder = Folder.new(@parent)
        yield(folder) if block_given?
        folder
      end

      def where(view = nil)
        @view = view
        self
      end

      private

      def build_response
        rep = @parent.sacc.get_all_folders(@parent.token, @view)
        fb = FoldersBuilder.new @parent, rep
        all = fb.make
        all.delete_if { |f| f.id == FolderDefault::ROOT[:id] }
      end

      def reset_query_params
        @view = nil
      end
    end
  end
end
