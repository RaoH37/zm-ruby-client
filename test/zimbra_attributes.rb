require 'minitest/autorun'

$LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__) + '/../lib')

require './lib/zm/client'

class TestZimbraAttributes < Minitest::Test

  def setup
    @admin = Zm::Client::Cluster.new(Zm::Client::ClusterConfig.new('./test/fixtures/config.yml'))
  end

  def test_all
    zac = Zm::Client::Base::ZimbraAttributesCollection.new(@admin)
    assert zac.all.is_a?(Array)
  end

  def test_not_empty
    zac = Zm::Client::Base::ZimbraAttributesCollection.new(@admin)
    assert !zac.all.empty?
  end

  def test_all_account
    zac = Zm::Client::Base::ZimbraAttributesCollection.new(@admin)
    assert !zac.all_account_attrs.empty?
  end

  # def test_all_account_version
  #   zac = Zm::Client::Base::ZimbraAttributesCollection.new(@admin)
  #   version = '8.6.0'
  #   attrs = zac.all_account_attrs_version(version)
  #
  #   assert attrs.length < zac.all_account_attrs.length
  # end

  def test_all_domain
    zac = Zm::Client::Base::ZimbraAttributesCollection.new(@admin)
    assert !zac.all_domain_attrs.empty?
  end

  def test_all_resource
    zac = Zm::Client::Base::ZimbraAttributesCollection.new(@admin)
    assert !zac.all_resource_attrs.empty?
  end

  def test_all_distributionlist
    zac = Zm::Client::Base::ZimbraAttributesCollection.new(@admin)
    assert !zac.all_distributionlist_attrs.empty?
  end
end
