# frozen_string_literal: true

module Zm
  module Client
    # class config for cluster connection
    class ClusterConfig
      attr_reader :to_h
      attr_accessor :zimbra_admin_host, :zimbra_admin_scheme,
                    :zimbra_admin_port, :zimbra_admin_login,
                    :zimbra_admin_password, :zimbra_public_host,
                    :zimbra_public_scheme, :zimbra_public_port,
                    :domains

      def initialize(file_config_path = nil)
        if block_given?
          yield(self)
          @to_h = instance_variables
        else
          init_from_json(file_config_path)
        end
      end

      def init_from_json(file_config_path)
        read_config_file(file_config_path)

        @zimbra_admin_host = @to_h[:zimbra_admin_host]
        @zimbra_admin_scheme = @to_h[:zimbra_admin_scheme]
        @zimbra_admin_port = @to_h[:zimbra_admin_port]
        @zimbra_admin_login = @to_h[:zimbra_admin_login]
        @zimbra_admin_password = @to_h[:zimbra_admin_password]
        @zimbra_public_host = @to_h[:zimbra_public_host]
        @zimbra_public_scheme = @to_h[:zimbra_public_scheme]
        @zimbra_public_port = @to_h[:zimbra_public_port]

        make_config_domain
      end

      def make_config_domain
        @domains = @to_h[:domains].map do |h|
          ClusterConfigDomain.new(h[:name], h[:key])
        end
      end

      def read_config_file(file_config_path)
        @to_h = JSON.parse(File.read(file_config_path), symbolize_names: true)
      end

      def find_domain(domain_name)
        @domains.find { |d| d.name == domain_name }
      end

      def domain_key(domain_name)
        domain = find_domain(domain_name)
        return nil if domain.nil?

        domain.key
      end
    end

    # class config for connection
    class ClusterConfigDomain
      attr_reader :name, :key

      def initialize(name, key)
        @name = name
        @key = key
      end
    end
  end
end
