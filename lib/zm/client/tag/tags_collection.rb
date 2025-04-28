# frozen_string_literal: true

module Zm
  module Client
    # collection account tags
    class TagsCollection < Base::AccountObjectsCollection
      def initialize(parent)
        @child_class = Tag
        @builder_class = TagBuilder
        super(parent)
      end

      private

      def make_query
        soap_request = SoapElement.mail(SoapMailConstants::GET_TAG_REQUEST)
        @parent.sacc.invoke(soap_request)
      end
    end
  end
end
