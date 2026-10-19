# frozen_string_literal: true

require_relative '../test_helper'

class ZimbraAttributesTest < ZmTest::UnitTest
  def teardown
    Zm::Client::Deprecation.instance_variable_set(:@warned, nil)
  end

  def test_accessors_are_declared_without_cluster
    assert Zm::Client::Account.method_defined?(:zimbraMailHost=)
    assert Zm::Client::Resource.method_defined?(:zimbraCalResType)
    assert Zm::Client::Domain.method_defined?(:zimbraDomainDefaultCOSId)
    assert Zm::Client::Cos.method_defined?(:zimbraMailQuota)
    assert Zm::Client::DistributionList.method_defined?(:zimbraMailStatus)
    assert Zm::Client::Server.method_defined?(:zimbraServiceEnabled)
  end

  def test_attrs_write_excludes_readonly_attributes
    attrs_write = Zm::Client::Account.attrs_write

    assert_includes attrs_write, 'zimbraMailHost'
    refute_includes attrs_write, 'zimbraId'
    assert_includes Zm::Client::Account.zimbra_attrs_readonly, :zimbraId
    assert_same attrs_write, Zm::Client::Account.new(nil).attrs_write
    assert_equal attrs_write.map { |name| :"@#{name}" }, Zm::Client::Account.attrs_write_ivars
  end

  def test_zimbra_attr_on_subclass_does_not_change_parent
    klass = Class.new(Zm::Client::Account) { zimbra_attr :zmTestOnlyAttr }

    assert klass.method_defined?(:zmTestOnlyAttr=)
    assert_includes klass.attrs_write, 'zmTestOnlyAttr'
    assert_includes klass.attrs_write, 'zimbraMailHost'
    refute_includes Zm::Client::Account.attrs_write, 'zmTestOnlyAttr'
  end

  def test_zimbra_attr_moves_attribute_between_writable_and_readonly
    klass = Class.new(Zm::Client::Account)
    klass.zimbra_attr :zimbraMailHost, readonly: true
    klass.zimbra_attr %i[zimbraId zimbraId]

    refute_includes klass.attrs_write, 'zimbraMailHost'
    assert_includes klass.zimbra_attrs_readonly, :zimbraMailHost
    assert_equal 1, klass.attrs_write.count('zimbraId')
    refute_includes klass.zimbra_attrs_readonly, :zimbraId
  end

  def test_create_sends_custom_writable_attributes_only
    cluster = logged_cluster
    @fake.on(:CreateAccountRequest) do |request|
      { CreateAccountResponse: { account: [ZmTest::FakeData.account(name: request.body[:name], id: 'new-id')] } }
    end
    klass = Class.new(Zm::Client::Account) { zimbra_attr :zmTestOnlyAttr }

    account = klass.new(cluster)
    account.name = 'new@domain.tld'
    account.zmTestOnlyAttr = 'custom'
    account.zimbraCreateTimestamp = '20260101000000Z'
    account.create!

    nodes = attr_nodes(@fake.last_request(:CreateAccountRequest).body)
    assert_includes nodes, { n: 'zmTestOnlyAttr', _content: 'custom' }
    refute(nodes.any? { |node| node[:n] == 'zimbraCreateTimestamp' })
  end

  def test_deprecated_cluster_zimbra_attributes
    cluster = Zm::Client::Cluster.new(build_config)

    _, first = capture_io { cluster.zimbra_attributes }
    _, second = capture_io { cluster.zimbra_attributes }
    attributes = cluster.zimbra_attributes

    assert_match(/Zm::Client::Cluster#zimbra_attributes is deprecated and will be removed in 4.0/, first)
    assert_includes first, __FILE__ unless ENV['RBS_TEST_TARGET']
    assert_empty second
    assert_same Zm::Client::Account.attrs_write, attributes.all_account_attrs_writable_names
    assert_equal Zm::Client::DistributionList.zimbra_attrs.map(&:name),
                 attributes.all_distributionlist_attrs.map(&:name)
    assert attributes.all_account_attrs.find { |attr| attr.name == 'zimbraId' }.immutable?
    assert_includes attributes.find { |attr| attr.name == 'cn' }.objects_scope, 'calendarResource'
  end

  def test_deprecated_zimbra_attributes_path
    config = build_config

    _, err = capture_io do
      config.zimbra_attributes_path = '/does/not/exist.csv'

      assert_nil config.zimbra_attributes_path
    end

    assert_match(/ClusterConfig#zimbra_attributes_path= is deprecated/, err)
    assert_match(/ClusterConfig#zimbra_attributes_path is deprecated/, err)
  end
end
