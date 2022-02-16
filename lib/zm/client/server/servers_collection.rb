# frozen_string_literal: true

module Zm
  module Client
    # Collection servers
    class ServersCollection < Base::AdminObjectsCollection
      def initialize(parent)
        @child_class = Server
        @builder_class = ServersBuilder
        @service = nil
        super(parent)
      end

      def find_by(hash)
        rep = sac.get_server(hash.values.first, hash.keys.first)
        entry = rep[:Body][:GetServerResponse][:server].first
        build_from_entry(entry)
      end

      def where(service)
        @service = service
        self
      end

      private

      def make_query
        sac.get_all_servers(@service)
      end
    end
  end
end
