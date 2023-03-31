require 'minitest/autorun'

$LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__) + '/../lib')

require './lib/zm/client'

class TestCluster < Minitest::Test

  def setup
    @config = Zm::Client::ClusterConfig.new('./test/fixtures/config.json')
    @admin = Zm::Client::Cluster.new(@config)
    @admin.login
  end

  def test_login
    assert @admin.logged?
  end

  def test_alive?
    assert @admin.alive?
  end

  def test_not_alive?
    admin = Zm::Client::Cluster.new(@config)
    admin.soap_admin_connector.token = '12345'
    assert !admin.alive?
  end

  def test_info
    @admin.infos!

    assert !@admin.type.nil?
    assert !@admin.version.nil?
    assert !@admin.release.nil?
    assert !@admin.buildDate.nil?
    assert !@admin.host.nil?
    assert !@admin.majorversion.nil?
    assert !@admin.minorversion.nil?
    assert !@admin.microversion.nil?
  end
end
