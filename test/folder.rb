require 'minitest/autorun'
require 'yaml'

$LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__) + '/../lib')

require './lib/zm/client'

class TestSearchFolder < Minitest::Test

  def setup
    @admin = Zm::Client::Cluster.new(Zm::Client::ClusterConfig.new('./test/fixtures/config.yml'))
    @admin.logger.debug!
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
      f.color = rand(1..5)
    end
    folder.create!
    assert !folder.id.nil?
  end

  def test_modify
    folder = @account.folders.all.reject { |folder| folder.id == Zm::Client::FolderDefault::ROOT[:id] }.first
    folder.color = (1..5).to_a.sample

    assert folder.modify!
  end

  def test_update
    folder = @account.folders.first
    colors = (1..5).to_a
    colors.delete(folder.color)
    selected_color = colors.sample

    begin
      is_modified = folder.update!(color: selected_color)
    rescue StandardError => _
      is_modified = false
    end

    assert is_modified
    assert selected_color == folder.color
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
    rescue StandardError => e
      puts e.message
      # puts e.backtrace.join("\n")
      is_modified = false
    end

    assert is_modified
  end

  def test_move
    folder = @account.folders.all.find { |f| !f.is_immutable? && f.l.to_i != 2 }
    current_l = folder.l
    folder.move!(2)

    assert folder.l != current_l
    assert folder.l == 2
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
    folder.rename!(new_name)

    folders = @account.folders.all!
    folder2 = folders.find { |f| f.name == new_name }

    assert !folder2.nil?
  end

  def test_default_parent_id
    folder = @account.folders.new do |f|
      f.name = "Test parent_id #{Time.now.to_i}"
      f.color = rand(1..5)
    end
    folder.create!
    assert folder.l == Zm::Client::FolderDefault::ROOT[:id]
  end
end
