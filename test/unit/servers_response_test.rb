# frozen_string_literal: true

require_relative '../test_helper'

class ServersResponseTest < ZmTest::UnitTest
  def setup
    super
    @cluster = logged_cluster
    all_servers(
      ['mbox1.domain.tld', %w[mailbox logger]],
      ['mta1.domain.tld', %w[mta]],
      ['mbox2.domain.tld', 'mailbox'],
      ['ldap1.domain.tld', %w[ldap proxy]]
    )
  end

  def test_all_returns_a_servers_response
    assert_instance_of Zm::Client::ServersResponse, @cluster.servers.all
  end

  def test_with_service_accepts_single_and_multiple_values
    servers = @cluster.servers.all.with_service('mailbox')

    assert_instance_of Zm::Client::ServersResponse, servers
    assert_equal %w[mbox1.domain.tld mbox2.domain.tld], servers.map(&:name)
  end

  def test_service_shortcuts
    servers = @cluster.servers.all

    assert_equal %w[mbox1.domain.tld mbox2.domain.tld], servers.mailbox_servers.map(&:name)
    assert_equal %w[mta1.domain.tld], servers.mta_servers.map(&:name)
    assert_equal %w[ldap1.domain.tld], servers.proxy_servers.map(&:name)
    assert_equal %w[ldap1.domain.tld], servers.ldap_servers.map(&:name)
    assert_empty servers.with_service('snmp')
  end

  def test_by_service_puts_a_server_in_each_of_its_services
    services = @cluster.servers.all.by_service

    assert_equal({ 'mailbox' => %w[mbox1.domain.tld mbox2.domain.tld], 'logger' => %w[mbox1.domain.tld],
                   'mta' => %w[mta1.domain.tld], 'ldap' => %w[ldap1.domain.tld], 'proxy' => %w[ldap1.domain.tld] },
                 services.transform_values { |servers| servers.map(&:name) })
    assert(services.values.all?(Zm::Client::ServersResponse))
  end

  def test_mailbox_servers_can_be_updated
    @fake.on(:ModifyServerRequest, { ModifyServerResponse: { server: [] } })

    @cluster.servers.all.mailbox_servers.update_all!(description: 'x')

    assert_equal(2, @fake.requests.count { |request| request.name == 'ModifyServerRequest' })
  end

  private

  def all_servers(*servers)
    json = servers.map do |name, services|
      { name:, id: SecureRandom.uuid, a: ZmTest::FakeData.attrs(zimbraServiceEnabled: services) }
    end
    @fake.on(:GetAllServersRequest, { GetAllServersResponse: { server: json } })
  end
end
