require 'minitest/autorun'
require 'yaml'

$LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__) + '/../lib')

require './lib/zm/client'

class TestShares < Minitest::Test

  def setup
    @admin = Zm::Client::Cluster.new(Zm::Client::ClusterConfig.new('./test/fixtures/config.yml'))
    @admin.login

    @fixture_accounts = YAML.load(File.read('./test/fixtures/accounts.yml'))
  end

  def test_all
    account = @admin.accounts.find_by name: @fixture_accounts['accounts']['maxime']['email']
    account.login
    assert account.shares.all.is_a?(Array)
    assert account.shares.all.any?
  end
end
