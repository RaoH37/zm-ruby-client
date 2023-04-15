require 'minitest/autorun'
require 'yaml'

$LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__) + '/../lib')

require './lib/zm/client'

class TestTAg < Minitest::Test

  def setup
    @admin = Zm::Client::Cluster.new(Zm::Client::ClusterConfig.new('./test/fixtures/config.yml'))
    # @admin.logger.debug!
    @admin.login

    @fixture_accounts = YAML.load(File.read('./test/fixtures/accounts.yml'))
    @account = @admin.accounts.find_by name: @fixture_accounts['accounts']['maxime']['email']
    @account.login
  end

  def test_all
    tags = @account.tags.all
    assert tags.is_a?(Array)
  end

  def test_create
    tag = @account.tags.new do |sf|
      sf.name = "test #{Time.now.to_i}"
      sf.color = 4
    end
    tag.create!
    assert !tag.id.nil?
  end

  def test_modify
    tag = @account.tags.first
    tag.color = (1..5).to_a.sample

    begin
      is_modified = tag.modify!
    rescue StandardError => _
      is_modified = false
    end

    assert is_modified
  end

  def test_delete
    tag = @account.tags.first
    tag.delete!
    assert tag.id.nil?
  end

  def test_rename
    tag = @account.tags.first
    new_name = "test rename #{Time.now.to_i}"
    tag.rename!(new_name)

    tags = @account.tags.all!
    tag2 = tags.find { |t| t.name == new_name }

    assert !tag2.nil?
  end
end
