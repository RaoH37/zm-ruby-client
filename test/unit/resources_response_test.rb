# frozen_string_literal: true

require_relative '../test_helper'

class ResourcesResponseTest < ZmTest::UnitTest
  def setup
    super
    @cluster = logged_cluster
  end

  def test_all_returns_a_resources_response
    search_resources(['room1@domain.tld', 'Location'])

    assert_instance_of Zm::Client::ResourcesResponse, @cluster.resources.all
  end

  def test_locations_and_equipments
    search_resources(['room1@domain.tld', 'Location'], ['projector@domain.tld', 'Equipment'],
                     ['room2@domain.tld', 'Location'])
    resources = @cluster.resources.all

    assert_instance_of Zm::Client::ResourcesResponse, resources.locations
    assert_equal %w[room1@domain.tld room2@domain.tld], resources.locations.map(&:name)
    assert_instance_of Zm::Client::ResourcesResponse, resources.equipments
    assert_equal %w[projector@domain.tld], resources.equipments.map(&:name)
  end

  def test_locations_can_be_updated
    search_resources(['room1@domain.tld', 'Location'], ['projector@domain.tld', 'Equipment'])
    @fake.on(:ModifyCalendarResourceRequest, { ModifyCalendarResourceResponse: { calresource: [] } })

    @cluster.resources.all.locations.update_all!(description: 'x')

    assert_equal(1, @fake.requests.count { |request| request.name == 'ModifyCalendarResourceRequest' })
  end

  def test_resources_without_type_are_in_neither
    search_resources(['room1@domain.tld', nil])
    resources = @cluster.resources.attrs('description').all

    assert_empty resources.locations
    assert_empty resources.equipments
  end

  def test_domain_resources_return_a_resources_response
    search_resources(['room1@domain.tld', 'Location'])
    domain = Zm::Client::Domain.new(@cluster) { |d| d.name = 'domain.tld' }

    assert_equal %w[room1@domain.tld], domain.resources.all.locations.map(&:name)
  end

  private

  def search_resources(*resources)
    json = resources.map do |name, type|
      { name:, id: SecureRandom.uuid, a: ZmTest::FakeData.attrs({ zimbraCalResType: type }.compact) }
    end
    @fake.on(:SearchDirectoryRequest, { SearchDirectoryResponse: { calresource: json, num: json.size } })
  end
end
