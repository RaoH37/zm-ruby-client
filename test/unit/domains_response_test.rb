# frozen_string_literal: true

require_relative '../test_helper'

class DomainsResponseTest < ZmTest::UnitTest
  def setup
    super
    @cluster = logged_cluster
  end

  def test_all_returns_a_domains_response
    search_domains(['domain.tld', 'local', 'active'])

    assert_instance_of Zm::Client::DomainsResponse, @cluster.domains.all
  end

  def test_locals_and_aliases
    search_domains(['domain.tld', 'local', 'active'], ['alias.tld', 'alias', 'active'],
                   ['other.tld', 'local', 'locked'])
    domains = @cluster.domains.all

    assert_instance_of Zm::Client::DomainsResponse, domains.locals
    assert_equal %w[domain.tld other.tld], domains.locals.map(&:name)
    assert_instance_of Zm::Client::DomainsResponse, domains.aliases
    assert_equal %w[alias.tld], domains.aliases.map(&:name)
  end

  def test_statuses_counts_the_domains_by_status
    search_domains(['domain.tld', 'local', 'active'], ['alias.tld', 'alias', 'active'],
                   ['other.tld', 'local', 'maintenance'])

    assert_equal({ 'active' => 2, 'maintenance' => 1 }, @cluster.domains.all.statuses)
  end

  def test_locals_can_be_updated
    search_domains(['domain.tld', 'local', 'active'], ['alias.tld', 'alias', 'active'])
    @fake.on(:ModifyDomainRequest, { ModifyDomainResponse: { domain: [] } })

    @cluster.domains.all.locals.update_all!(description: 'x')

    assert_equal(1, @fake.requests.count { |request| request.name == 'ModifyDomainRequest' })
  end

  def test_domains_without_type_and_status
    search_domains(['domain.tld', nil, nil])
    domains = @cluster.domains.attrs('description').all

    assert_empty domains.locals
    assert_empty domains.aliases
    assert_equal({ nil => 1 }, domains.statuses)
  end

  private

  def search_domains(*domains)
    json = domains.map do |name, type, status|
      attributes = { zimbraDomainType: type, zimbraDomainStatus: status }.compact
      { name:, id: SecureRandom.uuid, a: ZmTest::FakeData.attrs(attributes) }
    end
    @fake.on(:SearchDirectoryRequest, { SearchDirectoryResponse: { domain: json, num: json.size } })
  end
end
