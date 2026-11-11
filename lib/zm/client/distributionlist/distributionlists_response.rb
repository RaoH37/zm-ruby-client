# frozen_string_literal: true

module Zm
  module Client
    # distribution lists returned by DistributionListsCollection#all and find_in_batches
    class DistributionListsResponse < Base::AdminObjectsResponse
      def groups
        self.class.new(@collection, select(&:group?))
      end

      def mailing_lists
        self.class.new(@collection, select(&:mailing_list?))
      end
    end
  end
end
