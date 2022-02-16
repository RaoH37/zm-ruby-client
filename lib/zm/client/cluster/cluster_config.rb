# frozen_string_literal: true

require 'yaml'

module Zm
  module Client
    # class config for cluster connection
    class ClusterConfig
      attr_reader :to_h
      attr_accessor :zimbra_admin_host, :zimbra_admin_scheme,
                    :zimbra_admin_port, :zimbra_admin_login,
                    :zimbra_admin_password, :zimbra_public_host,
                    :zimbra_public_scheme, :zimbra_public_port,
                    :domains, :zimbra_version

      def initialize(parameters = nil)
        @zimbra_admin_scheme = 'https'
        @zimbra_admin_port = 7071
        @zimbra_public_scheme = 'https'
        @zimbra_public_port = 443
        @zimbra_version = '8.6.0'
        @domains = []

        if parameters.is_a?(String)
          init_from_file(parameters)
        elsif parameters.is_a?(Hash)
          @to_h = parameters
        end

        unless @to_h.nil?
          init_from_h
          make_config_domain
        end

        yield(self) if block_given?
      end

      def init_from_file(file_config_path)
        if file_config_path.end_with?('.json')
          init_from_json(file_config_path)
        elsif file_config_path.end_with?('.yml', '.yaml')
          init_from_yml(file_config_path)
        else
          raise ClusterConfigError, 'no valid config file extension'
        end
      end

      def init_from_h
        @zimbra_admin_host = @to_h[:zimbra_admin_host] unless @to_h[:zimbra_admin_host].nil?
        @zimbra_admin_scheme = @to_h[:zimbra_admin_scheme] unless @to_h[:zimbra_admin_scheme].nil?
        @zimbra_admin_port = @to_h[:zimbra_admin_port] unless @to_h[:zimbra_admin_port].nil?
        @zimbra_admin_login = @to_h[:zimbra_admin_login] unless @to_h[:zimbra_admin_login].nil?
        @zimbra_admin_password = @to_h[:zimbra_admin_password] unless @to_h[:zimbra_admin_password].nil?
        @zimbra_public_host = @to_h[:zimbra_public_host] unless @to_h[:zimbra_public_host].nil?
        @zimbra_public_scheme = @to_h[:zimbra_public_scheme] unless @to_h[:zimbra_public_scheme].nil?
        @zimbra_public_port = @to_h[:zimbra_public_port] unless @to_h[:zimbra_public_port].nil?
        @zimbra_version = @to_h[:zimbra_version] unless @to_h[:zimbra_version].nil?
      end

      def init_from_yml(file_config_path)
        @to_h = YAML.safe_load(File.read(file_config_path), symbolize_names: true)
      end

      def init_from_json(file_config_path)
        @to_h = JSON.parse(File.read(file_config_path), symbolize_names: true)
      end

      def make_config_domain
        return if @to_h[:domains].nil?

        @domains = @to_h[:domains].map do |h|
          ClusterConfigDomain.new(h[:name], h[:key])
        end
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

    # class error for config
    class ClusterConfigError < StandardError
    end
  end
end
