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

  def test_invalid_file_extension_raises
    assert_raises(Zm::Client::ClusterConfigError) { Zm::Client::ClusterConfig.new('config.txt') }
  end

  def test_default_zimbra_attributes_file_exists
    assert File.exist?(build_config.zimbra_attributes_path)
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

  def test_zimbra_attributes_are_loaded_from_csv
    attributes = Zm::Client::Cluster.new(build_config).zimbra_attributes

    refute_empty attributes.all_account_attrs
    refute_empty attributes.all_domain_attrs
    refute_empty attributes.all_distributionlist_attrs
    assert_kind_of Hash, attributes.all_account_attr_types_h
  end
end
