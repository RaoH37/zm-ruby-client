# frozen_string_literal: true

module Zm
  module Client
    # class factory [servers]
    class ServersBuilder < Base::ObjectsBuilder
      def make
        servers = []
        return servers if json_items.nil?

        json_items.each do |entry|
          server = Server.new
          server.set_soap_admin_connector(@soap_admin_connector)
          server.set_from_json(entry)
          servers << server
        end

        servers
      end

      private

      def json_items
        @json_items ||= @json[:Body][json_key][:server]
      end
    end
  end
end
