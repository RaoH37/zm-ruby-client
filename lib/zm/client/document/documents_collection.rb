# frozen_string_literal: true

module Zm
  module Client
    # collection of documents
    class DocumentsCollection < Base::ObjectsCollection
      DEFAULT_QUERY = 'in:briefcase'

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
        @folder_ids = @folders.map(&:id)
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
        @options = { resultMode: 1 }
        search_builder.ids
      end

      private

      def search_response
        rep = @parent.sacc.search(@parent.token, 'document', @offset, @limit, 'subjAsc', query, @options)
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

        return DEFAULT_QUERY if @folder_ids.empty?

        @folder_ids.map { |id| %(inid:"#{id}") }.join(' OR ')
      end

      def find_folder(document)
        @folders.find { |folder| folder.id == document.l }
      end

      def reset_query_params
        super
        @query = nil
        @folder_ids = []
        @folders = []
        @options = {}
      end
    end
  end
end
