# frozen_string_literal: true

module Zm
  module Client
    # collection account data sources
    class DataSourcesCollection < Base::AccountObjectsCollection
      def initialize(parent)
        @child_class = DataSource
        @builder_class = DataSourceBuilder
        super(parent)
      end

      private

      def make_query
        soap_request = SoapElement.mail(SoapMailConstants::GET_DATA_SOURCES_REQUEST)
        @parent.sacc.invoke(soap_request)
      end
    end
  end
end
