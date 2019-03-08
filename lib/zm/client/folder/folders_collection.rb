module Zm
  module Client
    class FoldersCollection < Base::ObjectsCollection
      METHODS_MISSING_LIST = %i[select each map length].to_set.freeze

      def initialize(soap_account_connector, account)
        @soap_account_connector = soap_account_connector
        @account = account
      end

      def new
        folder = Folder.new(@account)
        yield(folder) if block_given?
        folder
      end

      # def all
      #   @all_folders || where
      # end

      # def all!
      #   where!
      # end

      # def where(view = nil)
      #   rep = @soap_account_connector.get_all_folders(@account.token, view)
      #   fb = FoldersBuilder.new @account, rep
      #   all = fb.make
      #   all.delete_if { |f| f.id == FolderDefault::ROOT[:id] }
      # end

      # def where!(view = nil)
      #   @all_folders = where(view)
      # end

      def where(view = nil)
        @view = view
        self
      end

      # def folders(view = nil)
      #   select_type(:folder, view)
      # end

      # def links(view = nil)
      #   select_type(:link, view)
      # end

      private

      def build_response
        rep = @soap_account_connector.get_all_folders(@account.token, @view)
        fb = FoldersBuilder.new @account, rep
        all = fb.make
        all.delete_if { |f| f.id == FolderDefault::ROOT[:id] }
      end

      def reset_query_params
        @view = nil
      end

      # def select_type(type, view = nil)
      #   a = @all_folders.select { |f| f.type == type }
      #   a.select! { |f| f.view == view } unless view.nil?
      #   a
      # end
    end
  end
end
