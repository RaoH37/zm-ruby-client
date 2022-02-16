require 'minitest/autorun'
require 'yaml'

$LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__) + '/../lib')

require './lib/zm/client'

class TestSearchFolder < Minitest::Test

  def setup
    @admin = Zm::Client::Cluster.new(Zm::Client::ClusterConfig.new('./test/fixtures/config.yml'))
    # @admin.logger.debug!
    @admin.login

    @fixture_accounts = YAML.load(File.read('./test/fixtures/accounts.yml'))
    @account = @admin.accounts.find_by name: @fixture_accounts['accounts']['maxime']['email']
    @account.login
  end

  def test_all
    folders = @account.folders.all
    assert folders.is_a?(Array)
  end

  def test_find
    folder = @account.folders.find(10)
    assert folder.id.to_i == 10
  end

  def test_create
    folder = @account.folders.new do |f|
      f.name = "Test #{Time.now.to_i}"
      f.color = 5
    end
    folder.create!
    assert !folder.id.nil?
  end

  def test_modify
    folder = @account.folders.first
    folder.color = (1..5).to_a.sample

    begin
      is_modified = folder.modify!
    rescue StandardError => _
      is_modified = false
    end

    assert is_modified
  end

  def test_reload
    folder = @account.folders.first
    id = folder.id
    folder.reload!

    assert id == folder.id
  end

  def test_color
    folder = @account.folders.first
    folder.color = (1..5).to_a.sample

    begin
      is_modified = folder.color!
    rescue StandardError => _
      is_modified = false
    end

    assert is_modified
  end

  def test_move
    folder = @account.folders.all.find { |f| !f.is_immutable? && f.l.to_i != 2 }
    folder.l = 2

    begin
      is_modified = folder.move!
    rescue StandardError => _
      is_modified = false
    end

    assert is_modified
  end

  def test_empty
    folder = @account.folders.first
    folder.empty!
    assert folder.nb_items.zero?
  end

  def test_delete
    folder = @account.folders.all.find { |f| !f.is_immutable? }
    folder.delete!
    assert folder.id.nil?
  end

  def test_rename
    folder = @account.folders.all.find { |f| !f.is_immutable? }
    new_name = "Test #{Time.now.to_i}"
    folder.name = new_name
    folder.rename!

    folders = @account.folders.all!
    folder2 = folders.find { |f| f.name == new_name }

    assert !folder2.nil?
  end
end
