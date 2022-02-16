# frozen_string_literal: true

module Zm
  module Client
    # class factory [coses]
    class CosesBuilder < Base::ObjectsBuilder
      def initialize(parent, json)
        super(parent, json)
        @child_class = Cos
        @json_item_key = :cos
      end
    end
  end
end
