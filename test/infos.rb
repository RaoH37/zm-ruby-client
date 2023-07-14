require 'minitest/autorun'
require 'yaml'

$LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__) + '/../lib')

require './lib/zm/client'

class TestInfos < Minitest::Test

  def setup
    @admin = Zm::Client::Cluster.new(Zm::Client::ClusterConfig.new('./test/fixtures/config.yml'))
    @admin.login

    @fixture_accounts = YAML.load(File.read('./test/fixtures/accounts.yml'))
    @account = @admin.accounts.find_by name: @fixture_accounts['accounts']['maxime']['email']
    @account.login
  end

  def test_all
    infos = @account.infos.all
    assert infos.is_a?(Hash)
  end
end
