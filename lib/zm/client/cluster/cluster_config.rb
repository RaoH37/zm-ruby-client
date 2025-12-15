# frozen_string_literal: true

require 'yaml'

module Zm
  module Client
    # class config for cluster connection
    class ClusterConfig
      BASE_URL_REGEX = %r{\A(https?://[^/?#]+).*}

      attr_reader :to_h, :zimbra_admin_url, :zimbra_public_url
      attr_writer :logger, :colorize_logging
      attr_accessor :zimbra_admin_login, :zimbra_admin_password,
                    :domains, :zimbra_version, :log_path

      def initialize(parameters = nil)
        @domains = []
        @zimbra_version = '8.8.15'
        @log_path = $stdout
        @log_level = Logger::INFO
        @colorize_logging = true

        init_from_parameters(parameters)

        yield(self) if block_given?
      end

      def cache
        @cache = Zm::Support::Cache.registered_storage[cache_store_key]
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
        store_key = options.shift
        store_options = options.last
        store_class = Zm::Support::Cache.registered_storage[store_key]

        unless store_class || store_class.test_required_options(store_options)
          raise ClusterConfigError, 'invalid cache_store'
        end

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
        YAML.safe_load_file(file_config_path, symbolize_names: true)
      end

      def init_from_json(file_config_path)
        JSON.parse(File.read(file_config_path), symbolize_names: true)
      end

      def init_from_h(parameters)
        @zimbra_admin_login = parameters.delete(:zimbra_admin_login)
        @zimbra_admin_password = parameters.delete(:zimbra_admin_password)

        init_admin_url_from_parameters(parameters)

        init_public_url_from_parameters(parameters)

        if (version = parameters.delete(:zimbra_version))
          @zimbra_version = version
        end

        init_domains_from_parameters(parameters)
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
        @zimbra_attributes_path ||= "#{File.dirname(__FILE__)}../../../modules/common/zimbra-attrs.csv"
      end

      def zimbra_attributes_path=(path)
        raise ClusterConfigError, 'no valid attributes file' unless File.exist?(path)

        @zimbra_attributes_path = path
      end

      def logger
        return @logger if defined? @logger

        @logger = ZmLogger.new(@log_path).tap do |log|
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
    ClusterConfigDomain = Data.define(:name, :key)

    # class error for config
    class ClusterConfigError < StandardError; end
  end
end
