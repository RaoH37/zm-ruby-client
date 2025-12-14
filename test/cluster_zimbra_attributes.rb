require 'minitest/autorun'

$LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__) + '/../lib')

require './lib/zm/client'

class TestZimbraAttributes < Minitest::Test

  def setup
    @config = Zm::Client::ClusterConfig.new('./test/fixtures/config.yml')
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

  def test_first
    attr = @admin.zimbra_attributes.all.first
    assert attr.is_a?(Zm::Client::Base::ZimbraAttribute)
  end
end
