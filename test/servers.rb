require 'minitest/autorun'
require 'yaml'

$LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__) + '/../lib')

require './lib/zm/client'

class TestServers < Minitest::Test

  def setup
    @admin = Zm::Client::Cluster.new(Zm::Client::ClusterConfig.new('./test/fixtures/config.yml'))
    @admin.login

    @fixture_servers = YAML.load(File.read('./test/fixtures/servers.yml'))
  end

  def test_all
    assert @admin.servers.all.is_a? Array
  end

  def test_find
    server = @admin.servers.find_by name: @fixture_servers['servers']['default']['name']
    assert server.is_a? Zm::Client::Server
    assert_equal(@fixture_servers['servers']['default']['name'], server.name)
  end
end
