# frozen_string_literal: true

module Zm
  module Client
    # collection account tags
    class TagsCollection < Base::AccountObjectsCollection
      def initialize(parent)
        @child_class = Tag
        @builder_class = TagBuilder
        super
      end

      def make_query
        @parent.soap_connector.invoke(build_query)
      end

      def build_query
        SoapElement.mail(SoapMailConstants::GET_TAG_REQUEST)
      end
    end
  end
end
