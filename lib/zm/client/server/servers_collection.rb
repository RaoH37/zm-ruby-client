# frozen_string_literal: true

module Zm
  module Client
    # Collection servers
    class ServersCollection < Base::ObjectsCollection
      def initialize(parent)
        @parent = parent
        # @service = ServerServices::MAILBOX
        @service = nil
      end

      def find_by(hash)
        rep = sac.get_server(hash.values.first, hash.keys.first)
        entry = rep[:Body][:GetServerResponse][:server].first
        server = Server.new(@parent)
        server.init_from_json(entry)
        server
      end

      def where(service)
        @service = service
        self
      end

      private

      def build_response
        ServersBuilder.new(@parent, make_query).make
      end

      def make_query
        sac.get_all_servers(@service)
      end
    end
  end
end
