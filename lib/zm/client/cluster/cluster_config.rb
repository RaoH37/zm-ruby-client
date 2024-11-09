# frozen_string_literal: true

require 'yaml'

module Zm
  module Client
    # class config for cluster connection
    class ClusterConfig
      attr_reader :to_h
      attr_writer :logger, :colorize_logging
      attr_accessor :zimbra_admin_host, :zimbra_admin_scheme, :zimbra_admin_port, :zimbra_admin_login,
                    :zimbra_admin_password, :zimbra_public_host, :zimbra_public_scheme, :zimbra_public_port,
                    :domains, :zimbra_version, :log_path

      def initialize(parameters = nil)
        @domains = []
        @zimbra_version = '8.8.15'
        @log_path = $stdout
        @log_level = Logger::INFO
        @colorize_logging = true

        case parameters
        when String
          init_from_file(parameters)
        when Hash
          @to_h = parameters
        end

        unless @to_h.nil?
          init_from_h
          make_config_domain
        end

        yield(self) if block_given?
      end

      def cache_store
        @cache_store ||= Zm::Support::Cache.registered_storage[:null_store].new
      end

      def cache_store=(options)
        key = options.shift
        @cache_store = Zm::Support::Cache.registered_storage[key].new(**options.last)
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
        @zimbra_admin_host = @to_h.fetch(:zimbra_admin_host, nil)
        @zimbra_admin_scheme = @to_h.fetch(:zimbra_admin_scheme, 'https')
        @zimbra_admin_port = @to_h.fetch(:zimbra_admin_port, 7071)
        @zimbra_admin_login = @to_h.fetch(:zimbra_admin_login, nil)
        @zimbra_admin_password = @to_h.fetch(:zimbra_admin_password, nil)
        @zimbra_public_host = @to_h.fetch(:zimbra_public_host, nil)
        @zimbra_public_scheme = @to_h.fetch(:zimbra_public_scheme, 'https')
        @zimbra_public_port = @to_h.fetch(:zimbra_public_port, 443)
        @zimbra_version = @to_h.fetch(:zimbra_version, @zimbra_version)
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

      def has_admin_credentials?
        !@zimbra_admin_host.nil? && !@zimbra_admin_login.nil? && !@zimbra_admin_password.nil?
      end

      def zimbra_attributes_path
        @zimbra_attributes_path ||= "#{File.dirname(__FILE__)}../../../modules/common/zimbra-attrs.csv"
      end

      def zimbra_attributes_path=(path)
        raise ClusterConfigError, 'no valid attributes file' unless File.exist?(path)

        @zimbra_attributes_path = path
      end

      def logger
        @logger ||= ZmLogger.new(@log_path).tap do |log|
          log.level = @log_level
          log.colorize! if @colorize_logging
        end
      end

      def log_level=(level)
        return if level == @log_level

        logger.level = @log_level = level
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
    class ClusterConfigError < StandardError; end
  end
end
