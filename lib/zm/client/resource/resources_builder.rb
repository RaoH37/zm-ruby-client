# frozen_string_literal: true

module Zm
  module Client
    # class factory [resources]
    class ResourcesBuilder < Base::ObjectsBuilder
      def initialize(parent, json)
        super(parent, json)
        @child_class = Resource
        @json_item_key = :calresource
      end
    end
  end
end
