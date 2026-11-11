# frozen_string_literal: true

module Zm
  module Client
    # resources returned by ResourcesCollection#all and find_in_batches
    class ResourcesResponse < Base::AdminObjectsResponse
      def locations
        self.class.new(@collection, select(&:location?))
      end

      def equipments
        self.class.new(@collection, select(&:equipment?))
      end
    end
  end
end
