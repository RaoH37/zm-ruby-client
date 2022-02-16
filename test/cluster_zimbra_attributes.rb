require 'minitest/autorun'

$LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__) + '/../lib')

require './lib/zm/client'

class TestZimbraAttributes < Minitest::Test

  def setup
    @config = Zm::Client::ClusterConfig.new('./test/fixtures/config.json')
    @admin = Zm::Client::Cluster.new(@config)
  end

  def test_all
    assert @admin.zimbra_attributes.all.is_a?(Array)
  end

  def test_not_empty
    assert !@admin.zimbra_attributes.all.empty?
  end

  def test_all_account
    assert !@admin.zimbra_attributes.all_account_attrs.empty?
  end

  def test_all_account_version
    version = '8.6.0'
    attrs = @admin.zimbra_attributes.all_account_attrs_version(version)

    assert attrs.length < @admin.zimbra_attributes.all_account_attrs.length
  end

  def test_all_account_version_by_info
    @admin.login
    @admin.infos!
    assert !@admin.zimbra_attributes.all_account_attrs_version(@admin.version).empty?
  end
end
