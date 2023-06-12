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

      private

      def make_query
        soap_request = SoapElement.mail(SoapMailConstants::GET_SEARCH_FOLDER_REQUEST)
        @parent.sacc.invoke(soap_request)
      end
    end
  end
end
