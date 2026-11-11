# frozen_string_literal: true

module Zm
  module Client
    # domains returned by DomainsCollection#all and find_in_batches
    class DomainsResponse < Base::AdminObjectsResponse
      def locals
        self.class.new(@collection, select { |domain| domain.zimbraDomainType == Domain::LOCAL })
      end

      def aliases
        self.class.new(@collection, select { |domain| domain.zimbraDomainType == Domain::ALIAS })
      end

      def statuses
        each_with_object({}) do |domain, counts|
          status = domain.zimbraDomainStatus
          counts[status] = counts.fetch(status, 0) + 1
        end
      end
    end
  end
end
