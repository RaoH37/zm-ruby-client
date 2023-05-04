require 'minitest/autorun'

$LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__) + '/../lib')

require './lib/zm/client'

class TestAccount < Minitest::Test

  def setup
    @config = Zm::Client::ClusterConfig.new('./test/fixtures/config.yml')
    @fixture_accounts = YAML.load(File.read('./test/fixtures/accounts.yml'))

    @admin = Zm::Client::Cluster.new(@config)
    @admin.login
  end

  def test_all
    accounts = @admin.accounts.where(@fixture_accounts['collections']['where']['domain']).all
    assert accounts == @admin.accounts.all
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
    account = @admin.accounts.attrs('zimbraMailQuota').find_by name: @fixture_accounts['accounts']['maxime']['email']
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

  def test_attrs
    account = @admin.accounts.attrs('zimbraMailQuota').find_by name: @fixture_accounts['accounts']['maxime']['email']
    assert account.respond_to?(:zimbraMailQuota)
  end

  def test_has_quota
    accounts = @admin.accounts.where('(zimbraMailQuota=*)').per_page(10).attrs('zimbraMailQuota').all
    assert accounts.any?

    accounts.each do |account|
      assert account.zimbraMailQuota.is_a?(Integer)
    end
  end

  def test_quota
    email = @fixture_accounts['accounts']['maxime']['email']
    all = @admin.accounts.quotas(domain_name: email.split('@').last)
    assert all.is_a?(Array)
  end
end
