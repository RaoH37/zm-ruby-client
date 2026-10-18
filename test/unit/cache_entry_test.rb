# frozen_string_literal: true

require_relative '../test_helper'

class CacheEntryTest < Minitest::Test
  def test_registered_storages
    assert_equal Zm::Support::Cache::NullStore, Zm::Support::Cache.storage(:null_store)
    assert_equal Zm::Support::Cache::FileStore, Zm::Support::Cache.storage(:file_store)
    assert_nil Zm::Support::Cache.storage(:unknown_store)
  end

  def test_custom_storage_registration
    custom = Class.new(Zm::Support::Cache::NullStore)
    Zm::Support::Cache.register_storage(:custom_store, custom)

    assert_equal custom, Zm::Support::Cache.storage(:custom_store)
  ensure
    Zm::Support::Cache.registered_storage.delete(:custom_store)
  end

  def test_cache_entry_without_expires_at
    entry = Zm::Support::Cache::Entry.new('test')
    assert !entry.expired?
  end

  def test_cache_entry_future_expires_at
    entry = Zm::Support::Cache::Entry.new('test', expires_at: (Time.now + 300))
    assert !entry.expired?
  end

  def test_cache_entry_past_expires_at
    entry = Zm::Support::Cache::Entry.new('test', expires_at: (Time.now - 300))
    assert entry.expired?
  end

  def test_cache_entry_future_expires_in
    entry = Zm::Support::Cache::Entry.new('test', expires_in: 300)
    assert !entry.expired?
  end

  def test_cache_entry_past_expires_in
    entry = Zm::Support::Cache::Entry.new('test', expires_in: -300)
    assert entry.expired?
  end

  def test_cache_entry_dump
    entry = Zm::Support::Cache::Entry.new('test')
    assert entry.dump.is_a?(String)
  end

  def test_cache_entry_load
    entry = Zm::Support::Cache::Entry.new('test')
    dumped_entry = entry.dump
    restored_entry = Zm::Support::Cache::Entry.factory.load(dumped_entry)
    assert entry.value == restored_entry.value
  end

  def test_legacy_marshal_entry_is_ignored
    Dir.mktmpdir do |dir|
      store = Zm::Support::Cache::FileStore.new(cache_path: dir)
      store.write('key', 'value')
      path = Dir.glob(File.join(dir, '**', '*')).find { |f| File.file?(f) }
      legacy = MessagePack::ExtensionValue.new(0x01, [Marshal.dump('value')].to_msgpack).to_msgpack
      File.binwrite(path, legacy)

      assert_nil store.read('key')
    end
  end
end
