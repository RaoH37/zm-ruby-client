# frozen_string_literal: true

require_relative '../test_helper'

class CosesResponseTest < ZmTest::UnitTest
  def setup
    super
    @cluster = logged_cluster
    search_coses(
      ['default', { zimbraMailHostPool: %w[server-1 server-2], zimbraMailQuota: '0' }],
      ['small', { zimbraMailHostPool: 'server-2', zimbraMailQuota: '1073741824' }],
      ['vip', { zimbraMailHostPool: 'server-3', zimbraMailQuota: '0' }],
      ['partial', {}]
    )
  end

  def test_all_returns_a_coses_response
    assert_instance_of Zm::Client::CosesResponse, @cluster.coses.all
  end

  def test_with_server_accepts_an_id_or_a_server
    coses = @cluster.coses.all
    server = Zm::Client::Server.new(@cluster) { |s| s.id = 'server-2' }

    assert_instance_of Zm::Client::CosesResponse, coses.with_server('server-2')
    assert_equal %w[default small], coses.with_server('server-2').map(&:name)
    assert_equal %w[default small], coses.with_server(server).map(&:name)
    assert_empty coses.with_server('unknown')
  end

  def test_by_server_puts_a_cos_in_each_server_of_its_pool
    servers = @cluster.coses.all.by_server

    assert_equal({ 'server-1' => %w[default], 'server-2' => %w[default small], 'server-3' => %w[vip] },
                 servers.transform_values { |coses| coses.map(&:name) })
    assert(servers.values.all?(Zm::Client::CosesResponse))
  end

  def test_unlimited_quotas
    coses = @cluster.coses.all.unlimited_quotas

    assert_instance_of Zm::Client::CosesResponse, coses
    assert_equal %w[default vip], coses.map(&:name)
  end

  def test_unlimited_quotas_can_be_updated
    @fake.on(:ModifyCosRequest, { ModifyCosResponse: { cos: [] } })

    @cluster.coses.all.unlimited_quotas.update_all!(zimbraMailQuota: '10737418240')

    assert_equal(2, @fake.requests.count { |request| request.name == 'ModifyCosRequest' })
  end

  private

  def search_coses(*coses)
    json = coses.map { |name, attributes| { name:, id: SecureRandom.uuid, a: ZmTest::FakeData.attrs(attributes) } }
    @fake.on(:SearchDirectoryRequest, { SearchDirectoryResponse: { cos: json, num: json.size } })
  end
end
