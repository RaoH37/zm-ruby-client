# frozen_string_literal: true

require_relative '../test_helper'

class CacheEntryTest < Minitest::Test
  def test_registered_storages
    assert_equal Zm::Support::Cache::NullStore, Zm::Support::Cache.registered_storage[:null_store]
    assert_equal Zm::Support::Cache::FileStore, Zm::Support::Cache.registered_storage[:file_store]
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
end
