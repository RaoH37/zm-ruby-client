# frozen_string_literal: true

module Zm
  module Client
    # collection of documents
    class DocumentsCollection < Base::AccountSearchObjectsCollection
      DEFAULT_QUERY = 'in:briefcase'

      def initialize(parent)
        super(parent)
        @child_class = Document
        @builder_class = DocumentsBuilder
        @type = SoapConstants::DOCUMENT
        @sort_by = SoapConstants::DATE_ASC
      end

      def find_each
        @all = []

        @more = true
        @offset = 0
        @limit = 500

        while @more
          @all += build_response
          @offset += @limit
        end

        @all
      end

      private

      def query
        return @query unless @query.nil?

        return DEFAULT_QUERY if @folder_ids.empty?

        @folder_ids.map { |id| %(inid:"#{id}") }.join(' OR ')
      end
    end
  end
end
