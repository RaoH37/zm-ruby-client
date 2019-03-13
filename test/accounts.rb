require 'minitest/autorun'

$LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__) + '/../lib')

require './lib/zm/client'
require './lib/zm/client/cluster'
require './lib/zm/client/account'

class TestAccount < Minitest::Test
  
  def setup
    @admin = Zm::Client::Cluster.new(Zm::Client::ClusterConfig.new('./test/tmp/example.json'))
    @admin.login
    @account_name = "maxime@domain.tld"
    @domain_name = @account_name.split('@').last
    @domain = @admin.domains.find_by name: @domain_name
  end

  def test_all
    assert_raises Zm::Client::SoapError do 
      @admin.accounts.all.count.is_a? Integer
    end
  end

  def test_where
    assert_raises Zm::Client::SoapError do
      @admin.accounts.where("zimbraAccountStatus=active").count.is_a? Integer
    end
  end

  def test_where_chain
    assert_raises Zm::Client::SoapError do
      @admin.accounts.where('zimbraAccountStatus=active').order('givenName').attrs(:mail, :givenName, :sn)
    end
  end

  def test_find
    account = @admin.accounts.find_by name: @account_name
    assert_equal @account_name, account.name
  end

  def test_domain_all
    assert @domain.accounts.all.count.is_a? Integer
  end

  def test_domain_where
    assert @domain.accounts.where("zimbraAccountStatus=active").count.is_a? Integer
  end

  def test_domain_find
    account = @domain.accounts.find_by name: @account_name
    assert_equal @account_name, account.name
  end

  def test_domain_find_with_attrs
    account = @domain.accounts.find_by name: @account_name
      
    assert_equal @account_name, account.name
    refute_nil account.displayName
    refute_nil account.zimbraCOSId
  end

end