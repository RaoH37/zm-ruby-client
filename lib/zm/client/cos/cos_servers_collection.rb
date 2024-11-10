# frozen_string_literal: true

module Zm
  module Client
    # Collection Servers from cos
    class CosServersCollection
      def initialize(parent)
        @parent = parent
      end

      def all
        @all || all!
      end

      def all!
        @all = @parent.zimbraMailHostPool.map do |server_id|
          servers_collection.find_by(id: server_id)
        end
      end

      def add!(*servers)
        servers.flatten!
        server_ids = server_ids(servers)
        server_ids.delete_if { |id| @parent.zimbraMailHostPool.include?(id) }
        return false if server_ids.empty?

        payload = { zimbraMailHostPool: @parent.zimbraMailHostPool + server_ids }
        return false unless @parent.update!(payload)

        @parent.zimbraMailHostPool += server_ids
        true
      end

      def remove!(*servers)
        servers.flatten!
        server_ids = server_ids(servers)
        server_ids.delete_if { |id| !@parent.zimbraMailHostPool.include?(id) }
        return false if server_ids.empty?

        payload = { zimbraMailHostPool: @parent.zimbraMailHostPool - server_ids }
        return false unless @parent.update!(payload)

        @parent.zimbraMailHostPool += server_ids
        true
      end

      private

      def server_ids(servers)
        servers.select! { |server| server.is_a?(Zm::Client::Server) }
        ids = servers.map(&:id)
        ids.compact!
        ids.uniq!
        ids
      end

      def servers_collection
        @servers_collection ||= ServersCollection.new(@parent)
      end
    end
  end
end
