# frozen_string_literal: true

module Zm
  module Client
    # accounts returned by AccountsCollection#all and find_in_batches
    class AccountsResponse < Base::AdminObjectsResponse
      def by_server
        each_with_object({}) do |account, servers|
          (servers[account.zimbraMailHost] ||= self.class.new(@collection)) << account
        end
      end

      def statuses
        each_with_object({}) do |account, counts|
          status = account.zimbraAccountStatus
          counts[status] = counts.fetch(status, 0) + 1
        end
      end
    end
  end
end
