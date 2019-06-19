# frozen_string_literal: true

module Zm
  module Client
    # Collection servers
    class ServersCollection < Base::ObjectsCollection
      def initialize(parent)
        @parent = parent
      end

      def find_by(hash)
        rep = sac.get_server(hash.values.first, hash.keys.first)
        entry = rep[:Body][:GetServerResponse][:server].first
        server = Server.new(@parent)
        server.init_from_json(entry)
        server
      end

      # def where(services = nil)
      #   services = services.join(COMMA) if services.is_a?(Array)
      #   rep = @soap_admin_connector.get_all_servers(services)
      #   db = ServersBuilder.new @soap_admin_connector, rep
      #   db.make
      # end
    end
  end
end
