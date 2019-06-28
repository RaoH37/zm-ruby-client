# frozen_string_literal: true

module Zm
  module Client
    # class factory [servers]
    class ServersBuilder < Base::ObjectsBuilder
      def make
        return [] if json_items.nil?

        servers = json_items.map do |entry|
          server = Server.new(@parent)
          server.init_from_json(entry)
          server
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
