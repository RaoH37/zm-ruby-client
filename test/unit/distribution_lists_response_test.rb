# frozen_string_literal: true

require_relative '../test_helper'

class DistributionListsResponseTest < ZmTest::UnitTest
  def setup
    super
    @cluster = logged_cluster
  end

  def test_all_returns_a_distribution_lists_response
    search_lists(['group@domain.tld', 'disabled'])

    assert_instance_of Zm::Client::DistributionListsResponse, @cluster.distribution_lists.all
  end

  def test_groups_and_mailing_lists
    search_lists(['group1@domain.tld', 'disabled'], ['list@domain.tld', 'enabled'], ['group2@domain.tld', 'disabled'])
    lists = @cluster.distribution_lists.all

    assert_instance_of Zm::Client::DistributionListsResponse, lists.groups
    assert_equal %w[group1@domain.tld group2@domain.tld], lists.groups.map(&:name)
    assert_instance_of Zm::Client::DistributionListsResponse, lists.mailing_lists
    assert_equal %w[list@domain.tld], lists.mailing_lists.map(&:name)
  end

  def test_groups_can_be_updated
    search_lists(['group@domain.tld', 'disabled'], ['list@domain.tld', 'enabled'])
    @fake.on(:ModifyDistributionListRequest, { ModifyDistributionListResponse: { dl: [] } })

    @cluster.distribution_lists.all.groups.update_all!(description: 'x')

    assert_equal(1, @fake.requests.count { |request| request.name == 'ModifyDistributionListRequest' })
  end

  def test_lists_without_mail_status_are_in_neither
    search_lists(['list@domain.tld', nil])
    lists = @cluster.distribution_lists.attrs('description').all

    assert_empty lists.groups
    assert_empty lists.mailing_lists
  end

  def test_domain_distribution_lists_return_a_distribution_lists_response
    search_lists(['list@domain.tld', 'enabled'])
    domain = Zm::Client::Domain.new(@cluster) { |d| d.name = 'domain.tld' }

    assert_equal %w[list@domain.tld], domain.distribution_lists.all.mailing_lists.map(&:name)
  end

  private

  def search_lists(*lists)
    json = lists.map do |name, status|
      { name:, id: SecureRandom.uuid, a: ZmTest::FakeData.attrs({ zimbraMailStatus: status }.compact) }
    end
    @fake.on(:SearchDirectoryRequest, { SearchDirectoryResponse: { dl: json, num: json.size } })
  end
end
