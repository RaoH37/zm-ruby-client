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
        super
      end

      def find_by!(hash)
        entry = sac.invoke(build_find_by(hash))[:GetServerResponse][:server].first

        reset_query_params
        ServerJsnsInitializer.create(@parent, entry)
      end

      def build_find_by(hash)
        soap_request = SoapElement.admin(SoapAdminConstants::GET_SERVER_REQUEST)
        node_server = SoapElement.create(SoapConstants::SERVER)
                                 .add_attribute(SoapConstants::BY, hash.keys.first)
                                 .add_content(hash.values.first)
        soap_request.add_node(node_server)
        soap_request.add_attribute(SoapConstants::ATTRS, attrs_comma) unless @attrs.nil?
        soap_request
      end

      def where(service)
        @service = service
        self
      end

      def make_query
        sac.invoke(build_query)
      end

      def build_query
        soap_request = SoapElement.admin(SoapAdminConstants::GET_ALL_SERVERS_REQUEST)
        soap_request.add_attribute(SoapConstants::SERVICE, @service) unless @service.nil?
        soap_request
      end
    end
  end
end
