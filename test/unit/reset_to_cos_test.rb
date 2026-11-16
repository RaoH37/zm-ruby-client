# frozen_string_literal: true

require_relative '../test_helper'

class ResetToCosTest < ZmTest::UnitTest
  def setup
    super
    @cluster = logged_cluster
    @fake.on(:ModifyAccountRequest, { ModifyAccountResponse: { account: [] } })
  end

  def test_clears_the_attributes_equal_to_the_cos
    account = ldap_account(zimbraMailQuota: '1024', zimbraPrefMailItemsPerPage: '50',
                           zimbraFeatureCalendarEnabled: 'TRUE')
    stub_cos(zimbraMailQuota: '1024', zimbraPrefMailItemsPerPage: '100', zimbraFeatureCalendarEnabled: 'TRUE')

    assert_equal %i[zimbraFeatureCalendarEnabled zimbraMailQuota], account.reset_to_cos!.sort

    request = @fake.last_request(:ModifyAccountRequest)
    nodes = attr_nodes(request.body).sort_by { |node| node[:n] }

    assert_equal 'a1b2', request.body[:id]
    assert_equal [{ n: 'zimbraFeatureCalendarEnabled', _content: '' }, { n: 'zimbraMailQuota', _content: '' }], nodes
  end

  def test_compares_the_attributes_loaded_on_the_account
    account = ldap_account(zimbraMailQuota: '1024')
    stub_cos(zimbraMailQuota: '1024')
    requests_before = @fake.requests.size

    account.reset_to_cos!

    assert_equal %w[GetCosRequest ModifyAccountRequest], @fake.requests.drop(requests_before).map(&:name)
  end

  def test_clears_the_reset_attributes_on_the_account
    account = ldap_account(zimbraMailQuota: '1024', zimbraPrefMailItemsPerPage: '50')
    stub_cos(zimbraMailQuota: '1024', zimbraPrefMailItemsPerPage: '100')
    account.zimbraMailQuota = 1024

    account.reset_to_cos!

    assert_nil account.zimbraMailQuota
    assert_equal 50, account.zimbraPrefMailItemsPerPage
    refute account.zimbra_attr_changed?(:zimbraMailQuota)
    assert_empty account.reset_to_cos!
  end

  def test_ignores_the_attributes_not_inherited_from_the_cos
    account = ldap_account(description: 'same', zimbraNotes: 'same')
    stub_cos(description: 'same', zimbraNotes: 'same')

    assert_empty account.reset_to_cos!
    assert_nil @fake.last_request(:ModifyAccountRequest)
  end

  def test_compares_multi_valued_attributes
    account = ldap_account(zimbraAttachmentsBlocked: 'TRUE', zimbraPrefMailPollingInterval: %w[1m 2m])
    stub_cos(zimbraAttachmentsBlocked: 'FALSE', zimbraPrefMailPollingInterval: %w[1m 2m])

    assert_equal [:zimbraPrefMailPollingInterval], account.reset_to_cos!
  end

  def test_uses_the_given_cos_without_reading_it
    account = ldap_account(zimbraMailQuota: '1024')
    cos = @cluster.coses.new do |c|
      c.id = 'other-cos'
      c.zimbraMailQuota = 1024
    end

    assert_equal [:zimbraMailQuota], account.reset_to_cos!(cos:)
    assert_nil @fake.last_request(:GetCosRequest)
  end

  def test_uses_the_default_cos_of_the_domain_without_cos_id
    account = ldap_account(cos_id: nil, zimbraMailQuota: '1024')
    json = ZmTest::FakeData.account(name: 'domain.tld', id: 'd1', zimbraDomainDefaultCOSId: 'cos-id')
    @fake.on(:GetDomainRequest, { GetDomainResponse: { domain: [json] } })
    stub_cos(zimbraMailQuota: '1024')

    assert_equal [:zimbraMailQuota], account.reset_to_cos!
  end

  def test_resource_clears_the_attributes_equal_to_the_cos
    @fake.on(:ModifyCalendarResourceRequest, { ModifyCalendarResourceResponse: { calresource: [] } })
    resource = ldap_resource(zimbraMailQuota: '1024', zimbraPrefMailItemsPerPage: '50')
    stub_cos(zimbraMailQuota: '1024', zimbraPrefMailItemsPerPage: '100')

    assert_equal [:zimbraMailQuota], resource.reset_to_cos!

    request = @fake.last_request(:ModifyCalendarResourceRequest)

    assert_equal 'r1', request.body[:id]
    assert_equal [{ n: 'zimbraMailQuota', _content: '' }], attr_nodes(request.body)
    assert_nil resource.zimbraMailQuota
    assert_equal 50, resource.zimbraPrefMailItemsPerPage
  end

  def test_resource_uses_the_given_cos
    resource = ldap_resource(zimbraMailQuota: '1024')
    cos = @cluster.coses.new do |c|
      c.id = 'other-cos'
      c.zimbraMailQuota = 1024
    end
    @fake.on(:ModifyCalendarResourceRequest, { ModifyCalendarResourceResponse: { calresource: [] } })

    assert_equal [:zimbraMailQuota], resource.reset_to_cos!(cos:)
    assert_nil @fake.last_request(:GetCosRequest)
  end

  private

  def ldap_resource(**attributes)
    json = ZmTest::FakeData.account(name: 'room@domain.tld', id: 'r1', zimbraCOSId: 'cos-id', **attributes)
    @fake.on(:GetCalendarResourceRequest, { GetCalendarResourceResponse: { calresource: [json] } })
    @cluster.resources.ldap.find_by(name: 'room@domain.tld')
  end

  def ldap_account(cos_id: 'cos-id', **attributes)
    attributes[:zimbraCOSId] = cos_id unless cos_id.nil?
    json = ZmTest::FakeData.account(name: 'user@domain.tld', id: 'a1b2', **attributes)
    @fake.on(:GetAccountRequest, { GetAccountResponse: { account: [json] } })
    @cluster.accounts.ldap.find_by(name: 'user@domain.tld')
  end

  def stub_cos(**attributes)
    json = ZmTest::FakeData.account(name: 'cos', id: 'cos-id', **attributes)
    @fake.on(:GetCosRequest, { GetCosResponse: { cos: [json] } })
  end
end
