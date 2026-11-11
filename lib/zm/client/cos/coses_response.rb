# frozen_string_literal: true

module Zm
  module Client
    # classes of service returned by CosesCollection#all and find_in_batches
    class CosesResponse < Base::AdminObjectsResponse
      UNLIMITED_QUOTA = 0

      def with_server(server)
        server_id = server.is_a?(Server) ? server.id : server
        self.class.new(@collection, select { |cos| Array(cos.zimbraMailHostPool).include?(server_id) })
      end

      def by_server
        each_with_object({}) do |cos, servers|
          Array(cos.zimbraMailHostPool).each do |server_id|
            (servers[server_id] ||= self.class.new(@collection)) << cos
          end
        end
      end

      def unlimited_quotas
        self.class.new(@collection, select { |cos| cos.zimbraMailQuota == UNLIMITED_QUOTA })
      end
    end
  end
end
