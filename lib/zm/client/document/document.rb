# frozen_string_literal: true

module Zm
  module Client
    # class for account document
    class Document < Base::Object
      include BelongsToFolder
      include BelongsToTag

      attr_accessor :id, :uuid, :name, :s, :d, :l, :luuid, :ms, :mdver, :md, :rev, :f, :t, :meta, :ct,
                    :descEnabled, :ver, :leb, :cr, :cd, :acl, :loid, :sf, :tn

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

      def delete!
        return false if @id.nil?

        @parent.sacc.invoke(jsns_builder.to_delete)
        @id = nil
      end

      def reload!
        raise NotImplementedError
      end

      def download(dest_file_path)
        uploader = Upload.new(@parent, RestAccountConnector.new)
        uploader.download_file( Zm::Client::FolderDefault::ROOT[:path], nil, [Zm::Client::FolderView::DOCUMENT], [@id], dest_file_path)
      end

      private

      def jsns_builder
        @jsns_builder ||= DocumentJsnsBuilder.new(self)
      end
    end
  end
end
