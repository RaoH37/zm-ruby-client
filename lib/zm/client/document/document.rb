# frozen_string_literal: true

module Zm
  module Client
    # class for account document
    class Document < Base::Object
      include BelongsToFolder
      include BelongsToTag
      include RequestMethodsMailbox

      attr_accessor :id, :uuid, :name, :s, :d, :l, :luuid, :ms, :mdver, :md, :rev, :f, :t, :meta, :ct,
                    :descEnabled, :ver, :leb, :cr, :cd, :acl, :loid, :sf, :tn

      def create!
        raise NotImplementedError
      end

      def build_create
        raise NotImplementedError
      end

      def modify!
        raise NotImplementedError
      end

      def build_modify
        raise NotImplementedError
      end

      def update!(*args)
        raise NotImplementedError
      end

      def rename!(*args)
        raise NotImplementedError
      end

      def build_rename(*args)
        raise NotImplementedError
      end

      def reload!
        raise NotImplementedError
      end

      def download(dest_file_path)
        uploader = @parent.build_uploader
        uploader.download_file(dest_file_path, id, nil)
      end

      private

      def jsns_builder
        return @jsns_builder if defined? @jsns_builder

        @jsns_builder = DocumentJsnsBuilder.new(self)
      end
    end
  end
end
