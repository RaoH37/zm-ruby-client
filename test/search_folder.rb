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
    search_folders = @account.search_folders.all
    assert search_folders.is_a?(Array)
  end

  def test_create
    search_folder = @account.search_folders.new do |sf|
      sf.name = "Not read #{Time.now.to_i}"
      sf.query = 'is:unread'
    end
    search_folder.create!
    assert !search_folder.id.nil?
  end

  def test_modify
    search_folder = @account.search_folders.first
    search_folder.color = rand(1..5)
    search_folder.query = 'is:unread in:inbox'

    begin
      is_modified = search_folder.modify!
    rescue StandardError => _
      is_modified = false
    end

    assert is_modified
  end

  def test_delete
    search_folder = @account.search_folders.first
    search_folder.delete!
    assert search_folder.id.nil?
  end

  def test_rename
    search_folder = @account.search_folders.first
    new_name = "Not read renamed #{Time.now.to_i}"
    search_folder.rename!(new_name)

    sfs = @account.search_folders.all!
    sf2 = sfs.find { |t| t.name == new_name }

    assert !sf2.nil?
  end
end
