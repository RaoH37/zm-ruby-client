# frozen_string_literal: true

module Zm
  module Client
    # collection of documents
    class DocumentsCollection < Base::ObjectsCollection
      attr_accessor :more

      def initialize(parent)
        @parent = parent
        @more = true
        reset_query_params
      end

      def new
        document = Document.new(@parent)
        yield(document) if block_given?
        document
      end

      def start_at(start_at)
        @start_at = start_at
        self
      end

      def end_at(end_at)
        @end_at = end_at
        self
      end

      def folders(folders)
        @folders = folders
        @folder_ids += @folders.map(&:id)
        @folder_ids.uniq!
        self
      end

      def folder_ids(folder_ids)
        @folder_ids = folder_ids
        self
      end

      def where(query)
        @query = query
        self
      end

      def ids
        search_builder.ids
      end

      private

      def search_response
        rep = @parent.sacc.search(@parent.token, 'document', @offset, @limit, 'subjAsc', query)
        @more = rep[:Body][:SearchResponse][:more]
        rep
      end

      def search_builder
        DocumentsBuilder.new(@parent, search_response)
      end

      def build_response
        documents = search_builder.make
        documents.each { |appo| appo.folder = find_folder(appo) } unless @folders.empty?
        documents
      end

      def query
        return @query unless @query.nil?

        return nil if @folder_ids.empty?

        @folder_ids.map { |id| %Q{inid:"#{id}"} }.join(' OR ')
      end

      def find_folder(document)
        @folders.find { |folder| folder.id == document.l }
      end

      def reset_query_params
        super
        @query = 'in:briefcase'
        @folder_ids = []
        @folders = []
      end
    end
  end
end
