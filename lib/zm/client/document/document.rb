# frozen_string_literal: true

module Zm
  module Client
    # class for account document
    class Document < Base::AccountObject
      include BelongsToFolder

      attr_accessor :id, :uuid, :name, :s, :d, :l, :luuid, :ms, :mdver, :md, :rev, :f, :t, :meta, :ct,
                    :descEnabled, :ver, :leb, :cr, :cd, :acl, :loid, :sf, :tn

      def download(dest_file_path)
        uploader = Upload.new(@parent, RestAccountConnector.new)
        uploader.download_file(folder.absFolderPath, nil, nil, [id], dest_file_path)
      end

      private

      def jsns_builder
        @jsns_builder ||= DocumentJsnsBuilder.new(self)
      end
    end
  end
end
