require 'minitest/autorun'
require 'yaml'

$LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__) + '/../lib')

require './lib/zm/client'

class TestAccount < Minitest::Test

  def setup
    @admin = Zm::Client::Cluster.new(Zm::Client::ClusterConfig.new('./test/fixtures/config.yml'))
    @admin.login

    @fixture_accounts = YAML.load(File.read('./test/fixtures/accounts.yml'))
    @account = @admin.accounts.attrs('zimbraMailAlias').find_by name: @fixture_accounts['accounts']['maxime']['email']
  end

  def test_aliases_is_array
    assert @account.aliases.all.is_a?(Array)
  end

  def test_add_and_delete_alias
    new_alias = "unittest.alias.#{Time.now.to_i}@#{@account.domain_name}"
    @account.aliases.add!(new_alias)
    assert @account.aliases.all.include?(new_alias)
    @account.aliases.remove!(new_alias)
    assert !@account.aliases.all.include?(new_alias)
  end
end
