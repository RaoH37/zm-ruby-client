# frozen_string_literal: true

module Zm
  module Client
    # Collection servers
    # TODO: modifier l'héritage car SearchDirectoryRequest n'implémente pas le type Server
    class ServersCollection < Base::AdminObjectsCollection
      def initialize(parent)
        @child_class = Server
        @builder_class = ServersBuilder
        @service = nil
        super(parent)
      end

      def find_by!(hash)
        # rep = sac.get_server(hash.values.first, hash.keys.first)
        # entry = rep[:Body][:GetServerResponse][:server].first

        soap_request = SoapElement.admin(SoapAdminConstants::GET_SERVER_REQUEST)
        node_server = SoapElement.create('server').add_attribute('by', hash.keys.first).add_content(hash.values.first)
        soap_request.add_node(node_server)
        soap_request.add_attribute('attrs', attrs_comma) unless @attrs.nil?
        entry = sac.invoke(soap_request)[:GetServerResponse][:server].first

        reset_query_params
        ServerJsnsInitializer.create(@parent, entry)
      end

      def where(service)
        @service = service
        self
      end

      private

      def make_query
        jsns = @service.nil? ? nil : { service: @service }
        sac.jsns_request(:GetAllServersRequest, jsns)
      end
    end
  end
end
