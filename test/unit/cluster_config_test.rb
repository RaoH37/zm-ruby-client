# frozen_string_literal: true

require_relative '../test_helper'

class ClusterConfigTest < ZmTest::UnitTest
  def test_hash_with_host_scheme_and_port
    config = Zm::Client::ClusterConfig.new(
      zimbra_admin_host: 'webmail.domain.tld',
      zimbra_admin_scheme: 'https',
      zimbra_admin_port: 7071,
      zimbra_admin_login: 'admin@domain.tld',
      zimbra_admin_password: 'secret',
      zimbra_public_host: 'webmail.domain.tld',
      zimbra_public_scheme: 'https',
      zimbra_public_port: 443
    )

    assert_equal 'https://webmail.domain.tld:7071', config.zimbra_admin_url
    assert config.has_admin_credentials?
  end

  def test_missing_password_means_no_admin_credentials
    refute build_config(zimbra_admin_password: nil).has_admin_credentials?
  end

  def test_yaml_file
    Dir.mktmpdir do |dir|
      path = File.join(dir, 'config.yml')
      File.write(path, { 'zimbra_admin_url' => 'https://zimbra.test:7071', 'timeout' => 30 }.to_yaml)

      config = Zm::Client::ClusterConfig.new(path)

      assert_equal 'https://zimbra.test:7071', config.zimbra_admin_url
      assert_equal 30, config.timeout
    end
  end

  def test_log_path_from_parameters
    io = StringIO.new
    config = Zm::Client::ClusterConfig.new(zimbra_admin_url: 'https://zimbra.test:7071', log_path: io)
    config.logger.info('logged in the given device')

    assert_same io, config.log_path
    assert_includes io.string, 'logged in the given device'
  end

  def test_log_path_from_yaml_file
    Dir.mktmpdir do |dir|
      path = File.join(dir, 'config.yml')
      log_path = File.join(dir, 'zm.log')
      File.write(path, { 'zimbra_admin_url' => 'https://zimbra.test:7071', 'log_path' => log_path }.to_yaml)

      Zm::Client::ClusterConfig.new(path).logger.info('logged in the file')

      assert_includes File.read(log_path), 'logged in the file'
    end
  end

  def test_log_level_and_colorize_logging_from_parameters
    config = Zm::Client::ClusterConfig.new(zimbra_admin_url: 'https://zimbra.test:7071', log_path: File::NULL,
                                           log_level: Logger::DEBUG, colorize_logging: true)

    assert_equal Logger::DEBUG, config.logger.level
    assert_kind_of Zm::Client::ZmLogger::ZmLoggerColorized, config.logger
  end

  def test_log_level_and_colorize_logging_from_yaml_file
    Dir.mktmpdir do |dir|
      path = File.join(dir, 'config.yml')
      File.write(path, { 'zimbra_admin_url' => 'https://zimbra.test:7071', 'log_path' => File::NULL,
                         'log_level' => 'warn', 'colorize_logging' => 'yes' }.to_yaml)

      logger = Zm::Client::ClusterConfig.new(path).logger

      assert_equal Logger::WARN, logger.level
      refute_kind_of Zm::Client::ZmLogger::ZmLoggerColorized, logger
    end
  end

  def test_log_level_defaults_to_info_without_colors
    logger = build_config.logger

    assert_equal Logger::INFO, logger.level
    refute_kind_of Zm::Client::ZmLogger::ZmLoggerColorized, logger
  end

  def test_log_level_setter_accepts_a_name
    config = build_config
    config.log_level = :debug

    assert_equal Logger::DEBUG, config.logger.level
  end

  def test_invalid_log_level_raises
    assert_raises(ArgumentError) { build_config(log_level: 'verbose') }
  end

  def test_log_path_defaults_to_stdout
    assert_same $stdout, Zm::Client::ClusterConfig.new(zimbra_admin_url: 'https://zimbra.test:7071').log_path
  end

  def test_invalid_file_extension_raises
    assert_raises(Zm::Client::ClusterConfigError) { Zm::Client::ClusterConfig.new('config.txt') }
  end

  def test_default_cache_is_null_store
    assert_instance_of Zm::Support::Cache::NullStore, build_config.cache
  end

  def test_file_store_cache
    Dir.mktmpdir do |dir|
      config = build_config
      config.cache_store = :file_store, { cache_path: dir }

      assert_instance_of Zm::Support::Cache::FileStore, config.cache
      assert_equal dir, config.cache.cache_path
    end
  end

  def test_cache_is_memoized
    config = build_config

    assert_same config.cache, config.cache
  end

  def test_cache_store_does_not_mutate_argument
    Dir.mktmpdir do |dir|
      options = [:file_store, { cache_path: dir }]
      build_config.cache_store = options

      assert_equal [:file_store, { cache_path: dir }], options
    end
  end

  def test_cache_store_resets_cache
    Dir.mktmpdir do |dir|
      config = build_config
      config.cache
      config.cache_store = :file_store, { cache_path: dir }

      assert_instance_of Zm::Support::Cache::FileStore, config.cache
    end
  end

  def test_null_cache_store_is_accepted
    config = build_config
    config.cache_store = [:null_store]

    assert_instance_of Zm::Support::Cache::NullStore, config.cache
  end

  def test_unknown_cache_store_raises
    assert_raises(Zm::Client::ClusterConfigError) { build_config.cache_store = :unknown_store, {} }
  end

  def test_file_store_without_cache_path_raises
    assert_raises(Zm::Client::ClusterConfigError) { build_config.cache_store = :file_store, {} }
  end

  def test_ssl_verification_is_disabled_by_default
    config = build_config

    refute config.ssl_verify
    assert_equal Zm::Connector::SSL_VERIFY_NONE, config.ssl_options
  end

  def test_ssl_verification_from_parameters
    config = build_config(ssl_verify: true, ssl_ca_file: '/etc/ssl/zimbra.pem')

    assert_equal({ verify: true, verify_hostname: true, verify_mode: OpenSSL::SSL::VERIFY_PEER,
                   ca_file: '/etc/ssl/zimbra.pem' }, config.ssl_options)
  end

  def test_ssl_verify_only_accepts_true
    refute build_config(ssl_verify: 'false').ssl_verify
  end

  def test_connectors_use_ssl_options
    config = build_config(ssl_verify: true)
    cluster = Zm::Client::Cluster.new(config)
    account = cluster.accounts.new { |a| a.name = 'user@domain.tld' }

    assert cluster.soap_admin_connector.http_client!.ssl.verify?
    assert account.soap_account_connector.http_client!.ssl.verify?
    assert_equal config.ssl_options, account.rest_options[:ssl_options]
  end

  def test_connectors_skip_ssl_verification_by_default
    refute Zm::Client::Cluster.new(build_config).soap_admin_connector.http_client!.ssl.verify?
  end

  def test_deprecated_zimbra_version
    config = build_config

    _, err = capture_io do
      config.zimbra_version = '10.1.0'

      assert_equal '10.1.0', config.zimbra_version
    end

    assert_match(/ClusterConfig#zimbra_version= is deprecated/, err)
    assert_match(/ClusterConfig#zimbra_version is deprecated/, err)
  end

  def test_deprecated_zimbra_version_parameter
    _, err = capture_io { build_config(zimbra_version: '10.1.0') }

    assert_match(/zimbra_version parameter of Zm::Client::ClusterConfig is deprecated/, err)
  end

  def test_cluster_version_is_nil_before_infos
    _, err = capture_io { assert_nil Zm::Client::Cluster.new(build_config).version }

    assert_empty err
  end
end
