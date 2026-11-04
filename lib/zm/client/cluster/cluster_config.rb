# frozen_string_literal: true

require 'logger'

module Zm
  module Client
    # class config for cluster connection
    class ClusterConfig
      BASE_URL_REGEX = %r{\A(https?://[^/?#]+).*}
      ZIMBRA_VERSION_ADVICE = 'it is not used, call Cluster#infos! to read the server version with Cluster#version'

      attr_reader :zimbra_admin_url, :zimbra_public_url, :log_path
      attr_writer :logger, :colorize_logging
      attr_accessor :zimbra_admin_login, :zimbra_admin_password,
                    :domains, :timeout,
                    :ssl_verify, :ssl_ca_file, :ssl_ca_path

      def initialize(parameters = nil)
        @domains = []
        @zimbra_version = '8.8.15'
        @log_path = $stdout
        @log_level = Logger::INFO
        @colorize_logging = false
        @timeout = 300
        @ssl_verify = false

        init_from_parameters(parameters)

        yield(self) if block_given?
      end

      def cache
        @cache ||= Zm::Support::Cache.storage(cache_store_key)
                                     .new(**cache_store_options)
                                     .tap do |store|
                                       store.logger = logger
                                     end
      end

      def cache_store_key
        cache_store.first
      end

      def cache_store_options
        cache_store.last
      end

      def cache_store
        @cache_store ||= [:null_store, {}]
      end

      def cache_store=(options)
        store_key, store_options = options
        store_options ||= {}
        store_class = Zm::Support::Cache.storage(store_key)

        raise ClusterConfigError, 'invalid cache_store' unless store_class&.valid_options?(store_options)

        @cache = nil
        @cache_store = [store_key, store_options]
      end

      def init_from_parameters(parameters)
        case parameters
        when String
          init_from_h(init_from_file(parameters))
        when Hash
          init_from_h(parameters)
        end
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

      def init_from_yml(file_config_path)
        require 'yaml'
        YAML.safe_load_file(file_config_path, symbolize_names: true)
      end

      def init_from_json(file_config_path)
        JSON.parse(File.read(file_config_path), symbolize_names: true)
      end

      def init_from_h(parameters)
        parameters = parameters.dup
        @zimbra_admin_login = parameters.delete(:zimbra_admin_login)
        @zimbra_admin_password = parameters.delete(:zimbra_admin_password)

        init_admin_url_from_parameters(parameters)

        init_public_url_from_parameters(parameters)

        init_zimbra_version_from_parameters(parameters)

        if (p_timeout = parameters.delete(:timeout))
          @timeout = p_timeout.to_i
        end

        init_ssl_from_parameters(parameters)

        init_log_from_parameters(parameters)

        init_domains_from_parameters(parameters)
      end

      def init_zimbra_version_from_parameters(parameters)
        return unless (version = parameters.delete(:zimbra_version))

        Deprecation.warn_once('the zimbra_version parameter of Zm::Client::ClusterConfig', ZIMBRA_VERSION_ADVICE)
        @zimbra_version = version
      end

      def init_log_from_parameters(parameters)
        @log_path = parameters.delete(:log_path) if parameters.key?(:log_path)
        @log_level = Logger::Severity.coerce(parameters.delete(:log_level)) if parameters.key?(:log_level)
        @colorize_logging = parameters.delete(:colorize_logging) == true if parameters.key?(:colorize_logging)
      end

      def init_ssl_from_parameters(parameters)
        @ssl_verify = parameters.delete(:ssl_verify) == true if parameters.key?(:ssl_verify)
        @ssl_ca_file = parameters.delete(:ssl_ca_file) if parameters.key?(:ssl_ca_file)
        @ssl_ca_path = parameters.delete(:ssl_ca_path) if parameters.key?(:ssl_ca_path)
      end

      def ssl_options
        return Zm::Connector::SSL_VERIFY_NONE unless @ssl_verify

        Zm::Connector::SSL_VERIFY_PEER.merge(ca_file: @ssl_ca_file, ca_path: @ssl_ca_path).compact
      end

      def init_domains_from_parameters(parameters)
        if (config_domains = parameters.delete(:domains))
          @domains = config_domains.map do |h|
            ClusterConfigDomain.new(h[:name], h[:key])
          end
        end
      end

      def init_public_url_from_parameters(parameters)
        if (url = parameters.delete(:zimbra_public_url))
          self.zimbra_public_url = url
        elsif (host = parameters.delete(:zimbra_public_host))
          scheme = parameters.delete(:zimbra_public_scheme) || 'https'
          port = parameters.delete(:zimbra_public_port) || 443

          self.zimbra_public_url = "#{scheme}://#{host}:#{port}"
        end
      end

      def init_admin_url_from_parameters(parameters)
        if (url = parameters.delete(:zimbra_admin_url))
          self.zimbra_admin_url = url
        else
          scheme = parameters.delete(:zimbra_admin_scheme) || 'https'
          host = parameters.delete(:zimbra_admin_host)
          port = parameters.delete(:zimbra_admin_port) || 7071

          self.zimbra_admin_url = "#{scheme}://#{host}:#{port}"
        end
      end

      def zimbra_admin_url=(url)
        match_data = BASE_URL_REGEX.match(url)

        raise ClusterConfigError, 'no valid zimbra_admin_url configuration' unless match_data

        @zimbra_admin_url = match_data[1]
      end

      def zimbra_public_url=(url)
        match_data = BASE_URL_REGEX.match(url)

        raise ClusterConfigError, 'no valid zimbra_public_url configuration' unless match_data

        @zimbra_public_url = match_data[1]
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
        !@zimbra_admin_url.nil? && !@zimbra_admin_login.nil? && !@zimbra_admin_password.nil?
      end

      def zimbra_attributes_path
        Deprecation.warn_once('Zm::Client::ClusterConfig#zimbra_attributes_path', 'it always returns nil')
        nil
      end

      def zimbra_attributes_path=(_path)
        Deprecation.warn_once('Zm::Client::ClusterConfig#zimbra_attributes_path=',
                              'declare custom attributes with zimbra_attr (Zm::Client::Account.zimbra_attr :myAttr)')
      end

      def zimbra_version
        Deprecation.warn_once('Zm::Client::ClusterConfig#zimbra_version', ZIMBRA_VERSION_ADVICE)
        @zimbra_version
      end

      def zimbra_version=(version)
        Deprecation.warn_once('Zm::Client::ClusterConfig#zimbra_version=', ZIMBRA_VERSION_ADVICE)
        @zimbra_version = version
      end

      def logger
        return @logger if defined? @logger

        @logger = ZmLogger.new(@log_path).tap do |log|
          log.level = @log_level
          log.colorize! if @colorize_logging
        end
      end

      def log_path=(path)
        @log_path = path
        @logger.log_path = path if defined?(@logger) && @logger.is_a?(ZmLogger)
      end

      def log_level=(level)
        level = Logger::Severity.coerce(level)
        return if level == @log_level

        logger.level = @log_level = level
      end
    end

    # class config for connection
    ClusterConfigDomain = Data.define(:name, :key)

    # class error for config
    class ClusterConfigError < StandardError; end
  end
end
