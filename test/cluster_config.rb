require 'minitest/autorun'

$LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__) + '/../lib')

require './lib/zm/client'

class TestClusterConfig < Minitest::Test
  def test_yaml_path
    assert Zm::Client::ClusterConfig.new('./test/fixtures/config.yml').is_a? Zm::Client::ClusterConfig
  end

  def test_hash
    config_h = {
      zimbra_admin_host: 'webmail.domain.tld',
      zimbra_admin_scheme: 'https',
      zimbra_admin_port: 7071,
      zimbra_admin_login: 'admin@domain.tld',
      zimbra_admin_password: 'secret',
      zimbra_public_host: 'webmail.domain.tld',
      zimbra_public_scheme: 'https',
      zimbra_public_port: 443
    }
    assert Zm::Client::ClusterConfig.new(config_h).is_a? Zm::Client::ClusterConfig
  end
end
