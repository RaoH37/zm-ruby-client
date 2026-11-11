# frozen_string_literal: true

module Zm
  module Client
    # servers returned by ServersCollection#all
    class ServersResponse < Base::AdminObjectsResponse
      def with_service(service)
        self.class.new(@collection, select { |server| service_enabled?(server, service) })
      end

      def mailbox_servers
        with_service(ServerServices::MAILBOX)
      end

      def mta_servers
        with_service(ServerServices::MTA)
      end

      def proxy_servers
        with_service(ServerServices::PROXY)
      end

      def ldap_servers
        with_service(ServerServices::LDAP)
      end

      def by_service
        each_with_object({}) do |server, services|
          Array(server.zimbraServiceEnabled).each do |service|
            (services[service] ||= self.class.new(@collection)) << server
          end
        end
      end

      private

      def service_enabled?(server, service)
        services = server.zimbraServiceEnabled
        services.is_a?(Array) ? services.include?(service) : services == service
      end
    end
  end
end
