# frozen_string_literal: true

require_relative '../test_helper'

class CosAssignmentTest < ZmTest::UnitTest
  def setup
    super
    @cluster = logged_cluster
  end

  def test_account_cos_is_nil_without_cos_id
    account = find_account

    assert_nil account.cos
    assert_nil @fake.last_request(:GetCosRequest)
  end

  def test_account_cos_is_read_again_when_the_cos_id_changes
    account = find_account(zimbraCOSId: 'cos-a')
    stub_cos('cos-a')

    assert_equal 'cos-a', account.cos.id
    assert_same account.cos, account.cos

    stub_cos('cos-b')
    account.zimbraCOSId = 'cos-b'

    assert_equal 'cos-b', account.cos.id
  end

  def test_account_cos_setter_sets_the_cos_and_tracks_its_id
    account = find_account(zimbraCOSId: 'cos-a')
    cos = recorded_cos('cos-b')

    account.cos = cos

    assert_same cos, account.cos
    assert_equal 'cos-b', account.zimbraCOSId
    assert account.zimbra_attr_changed?(:zimbraCOSId)
  end

  def test_account_cos_setter_accepts_nil
    account = find_account(zimbraCOSId: 'cos-a')

    account.cos = nil

    assert_nil account.cos
    assert_nil account.zimbraCOSId
    assert account.zimbra_attr_changed?(:zimbraCOSId)
  end

  def test_account_cos_setter_rejects_an_unrecorded_cos_or_another_object
    account = find_account(zimbraCOSId: 'cos-a')

    assert_raises(ArgumentError) { account.cos = @cluster.coses.new }
    assert_raises(ArgumentError) { account.cos = 'cos-b' }
    assert_equal 'cos-a', account.zimbraCOSId
    refute account.zimbra_attr_changed?(:zimbraCOSId)
  end

  def test_domain_cos_is_read_again_when_the_cos_id_changes
    domain = find_domain(zimbraDomainDefaultCOSId: 'cos-a')
    stub_cos('cos-a')

    assert_equal 'cos-a', domain.cos.id

    stub_cos('cos-b')
    domain.zimbraDomainDefaultCOSId = 'cos-b'

    assert_equal 'cos-b', domain.cos.id
  end

  def test_domain_cos_setter_sets_the_cos_and_tracks_its_id
    domain = find_domain(zimbraDomainDefaultCOSId: 'cos-a')
    cos = recorded_cos('cos-b')

    domain.cos = cos

    assert_same cos, domain.cos
    assert_equal 'cos-b', domain.zimbraDomainDefaultCOSId
    assert domain.zimbra_attr_changed?(:zimbraDomainDefaultCOSId)
  end

  def test_domain_cos_setter_accepts_nil
    domain = find_domain(zimbraDomainDefaultCOSId: 'cos-a')

    domain.cos = nil

    assert_nil domain.cos
    assert_nil domain.zimbraDomainDefaultCOSId
  end

  def test_domain_cos_setter_rejects_an_unrecorded_cos
    domain = find_domain(zimbraDomainDefaultCOSId: 'cos-a')

    assert_raises(ArgumentError) { domain.cos = @cluster.coses.new }
    assert_equal 'cos-a', domain.zimbraDomainDefaultCOSId
  end

  def test_resource_cos_setter_sets_the_cos_and_tracks_its_id
    resource = find_resource
    cos = recorded_cos('cos-b')

    assert_nil resource.cos

    resource.cos = cos

    assert_same cos, resource.cos
    assert_equal 'cos-b', resource.zimbraCOSId
    assert resource.zimbra_attr_changed?(:zimbraCOSId)
    assert_raises(ArgumentError) { resource.cos = @cluster.coses.new }
  end

  def test_account_effective_cos_is_its_own_cos
    account = find_account(zimbraCOSId: 'cos-a')
    stub_cos('cos-a')

    assert_equal 'cos-a', account.effective_cos.id
    assert_nil @fake.last_request(:GetDomainRequest)
  end

  def test_account_effective_cos_is_the_default_cos_of_its_domain
    account = find_account
    find_domain(zimbraDomainDefaultCOSId: 'cos-d')
    stub_cos('cos-d')

    assert_equal 'cos-d', account.effective_cos.id
    assert_includes @fake.last_request(:GetDomainRequest).body.to_s, 'domain.tld'
  end

  def test_account_effective_cos_is_the_default_cos_without_domain_cos
    account = find_account
    find_domain
    stub_cos('default-id')

    assert_equal 'default-id', account.effective_cos.id
    assert_includes @fake.last_request(:GetCosRequest).body.to_s, Zm::Client::Base::HasCos::DEFAULT_COS_NAME
  end

  def test_resource_effective_cos_is_the_default_cos_of_its_domain
    resource = find_resource
    find_domain(zimbraDomainDefaultCOSId: 'cos-d')
    stub_cos('cos-d')

    assert_equal 'cos-d', resource.effective_cos.id
  end

  def test_domain_has_no_effective_cos
    refute_respond_to Zm::Client::Domain.allocate, :effective_cos
  end

  private

  def find_resource(**attributes)
    json = ZmTest::FakeData.account(name: 'room@domain.tld', id: 'r1', **attributes)
    @fake.on(:GetCalendarResourceRequest, { GetCalendarResourceResponse: { calresource: [json] } })
    @cluster.resources.find_by(name: 'room@domain.tld')
  end

  def find_account(**attributes)
    json = ZmTest::FakeData.account(name: 'user@domain.tld', id: 'a1b2', **attributes)
    @fake.on(:GetAccountRequest, { GetAccountResponse: { account: [json] } })
    @cluster.accounts.find_by(name: 'user@domain.tld')
  end

  def find_domain(**attributes)
    json = ZmTest::FakeData.account(name: 'domain.tld', id: 'd1', **attributes)
    @fake.on(:GetDomainRequest, { GetDomainResponse: { domain: [json] } })
    @cluster.domains.find_by(name: 'domain.tld')
  end

  def stub_cos(id)
    @fake.on(:GetCosRequest, { GetCosResponse: { cos: [ZmTest::FakeData.account(name: id, id:)] } })
  end

  def recorded_cos(id)
    @cluster.coses.new do |cos|
      cos.id = id
      cos.name = id
    end
  end
end
