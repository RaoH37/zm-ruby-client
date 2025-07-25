# frozen_string_literal: true

module Zm
  module Client
    # collection of search folders
    class SearchFoldersCollection < Base::AccountObjectsCollection
      def initialize(parent)
        @child_class = SearchFolder
        @builder_class = SearchFoldersBuilder
        super(parent)
      end

      def make_query
        @parent.soap_connector.invoke(build_query)
      end

      def build_query
        SoapElement.mail(SoapMailConstants::GET_SEARCH_FOLDER_REQUEST)
      end
    end
  end
end
