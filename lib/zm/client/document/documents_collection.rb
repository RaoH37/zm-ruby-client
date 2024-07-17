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

      def find_each(offset: 0, limit: 500, &block)
        @more = true
        @offset = offset
        @limit = limit

        while @more
          build_response.each { |item| block.call(item) }
          @offset += @limit
        end
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
