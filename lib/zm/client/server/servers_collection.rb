# frozen_string_literal: true

module Zm
  module Client
    # Collection servers
    class ServersCollection < Base::ObjectsCollection
      def initialize(parent)
        @parent = parent
        @services = [ServerServices::MAILBOX]
      end

      def find_by(hash)
        rep = sac.get_server(hash.values.first, hash.keys.first)
        entry = rep[:Body][:GetServerResponse][:server].first
        server = Server.new(@parent)
        server.init_from_json(entry)
        server
      end

      def where(*services)
        @services = services
      end

      private

      def build_response
        ServersBuilder.new(@parent, make_query).make
      end

      def make_query
        sac.get_all_servers(@services.join(COMMA))
      end
    end
  end
end
