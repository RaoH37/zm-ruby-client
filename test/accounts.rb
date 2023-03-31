require 'minitest/autorun'
require 'yaml'

$LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__) + '/../lib')

require './lib/zm/client'

class TestAccount < Minitest::Test

  def setup
    @admin = Zm::Client::Cluster.new(Zm::Client::ClusterConfig.new('./test/fixtures/config.yml'))
    @admin.login

    @fixture_accounts = YAML.load(File.read('./test/fixtures/accounts.yml'))
  end

  def test_all
    accounts = @admin.accounts.where(@fixture_accounts['collections']['where']['domain']).all
    assert accounts == @admin.accounts.where(@fixture_accounts['collections']['where']['domain']).all
  end

  def test_all_is_account
    accounts = @admin.accounts.where(@fixture_accounts['collections']['where']['domain']).all
    assert accounts.map(&:class).uniq.first == Zm::Client::Account
  end

  def test_all_where
    accounts = @admin.accounts.where(@fixture_accounts['collections']['where']['domain']).all
    assert accounts != @admin.accounts.where(@fixture_accounts['collections']['where']['domain_active']).all
  end

  def test_all!
    accounts = @admin.accounts.where(@fixture_accounts['collections']['where']['domain']).all
    assert accounts != @admin.accounts.where(@fixture_accounts['collections']['where']['domain']).all!
  end

  def test_where
    assert @admin.accounts.where(@fixture_accounts['collections']['where']['domain']).count.is_a? Integer
  end

  def test_where_chain
    where_clause = @fixture_accounts['collections']['where']['domain']
    order_clause = @fixture_accounts['collections']['order']['default']
    attrs_clause = @fixture_accounts['collections']['attrs']['default']
    assert @admin.accounts.where(where_clause).order(order_clause).attrs(*attrs_clause).all.any?
  end

  def test_find_by_name
    account = @admin.accounts.find_by name: @fixture_accounts['accounts']['maxime']['email']
    assert account.is_a? Zm::Client::Account
    assert_equal @fixture_accounts['accounts']['maxime']['email'], account.name
  end

  def test_new_account
    name = @fixture_accounts['accounts']['toto']['email']
    account = @admin.accounts.new do |acc|
      acc.name = name
    end
    assert account.is_a? Zm::Client::Account
    assert account.name == name
  end
end
