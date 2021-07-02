require 'minitest/autorun'

$LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__) + '/../lib')

require './lib/zm/client'

class TestAccount < Minitest::Test

  def setup
    @admin = Zm::Client::Cluster.new(Zm::Client::ClusterConfig.new('./test/tmp/example.json'))
    @admin.login
    @account_name = "maxime@domain.tld"
    @domain_name = @account_name.split('@').last.freeze
    @filter = "(zimbraMailDeliveryAddress=*@#{@domain_name})".freeze
    @filter_2 = "(&(zimbraMailDeliveryAddress=*@#{@domain_name})(zimbraAccountStatus=active))".freeze
    @domain = @admin.domains.find_by name: @domain_name
  end

  def test_all
    accounts = @admin.accounts.where(@filter).all
    assert accounts == @admin.accounts.where(@filter).all
  end

  def test_all_where
    accounts = @admin.accounts.where(@filter).all
    assert accounts != @admin.accounts.where(@filter_2).all
  end

  def test_all!
    accounts = @admin.accounts.where(@filter).all
    assert accounts != @admin.accounts.where(@filter).all!
  end

  def test_where
    assert @admin.accounts.where(@filter).count.is_a? Integer
  end

  def test_where_chain
    assert @admin.accounts.where(@filter).order('givenName').attrs(:mail, :givenName, :sn).all.any?
  end

  def test_find_by_name
    account = @admin.accounts.find_by name: @account_name
    assert_equal @account_name, account.name
  end

  def test_domain_find_with_attrs
    account = @domain.accounts.find_by name: @account_name

    assert_equal @account_name, account.name
    refute_nil account.displayName
    refute_nil account.zimbraCOSId
  end
end
