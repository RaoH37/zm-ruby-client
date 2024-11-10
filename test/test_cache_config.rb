require 'minitest/autorun'
require 'yaml'

$LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__) + '/../lib')
require 'zm-ruby-client'

class TestCacheConfig < Minitest::Test
  def setup

  end

  def test_cache_registered_storage_not_empty
    assert !Zm::Support::Cache.registered_storage.empty?
  end

  def test_respond_to_cache_store
    cluster_config = Zm::Client::ClusterConfig.new('./test/fixtures/config.yml')
    assert cluster_config.respond_to?(:cache_store)
  end

  def test_default_cache_null_store
    cluster_config = Zm::Client::ClusterConfig.new('./test/fixtures/config.yml')
    assert cluster_config.cache_store.is_a?(Zm::Support::Cache::NullStore)
  end

  def test_cache_registered_storage
    assert Zm::Support::Cache.registered_storage[:null_store] == Zm::Support::Cache::NullStore
    assert Zm::Support::Cache.registered_storage[:file_store] == Zm::Support::Cache::FileStore
  end

  def test_cache_is_file_store
    cache_path = '/tmp'

    cluster_config = Zm::Client::ClusterConfig.new('./test/fixtures/config.yml') do |cc|
      cc.cache_store = :file_store, { cache_path: cache_path }
    end

    assert cluster_config.cache_store.is_a?(Zm::Support::Cache::FileStore)
    assert cluster_config.cache_store.cache_path == cache_path
  end
end
