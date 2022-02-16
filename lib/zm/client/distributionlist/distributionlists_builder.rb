# frozen_string_literal: true

module Zm
  module Client
    # class factory [dls]
    class DistributionListsBuilder < Base::ObjectsBuilder
      def initialize(parent, json)
        super(parent, json)
        @child_class = DistributionList
        @json_item_key = :dl
      end
    end
  end
end
