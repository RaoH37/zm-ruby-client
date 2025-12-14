# frozen_string_literal: true

module Zm
  module Client
    # collection account data sources
    class DataSourcesCollection < Base::AccountObjectsCollection
      def initialize(parent)
        @child_class = DataSource
        @builder_class = DataSourceBuilder
        super
      end

      def make_query
        @parent.soap_connector.invoke(build_query)
      end

      def build_query
        SoapElement.mail(SoapMailConstants::GET_DATA_SOURCES_REQUEST)
      end
    end
  end
end
