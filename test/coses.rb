require 'minitest/autorun'
require 'yaml'

$LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__) + '/../lib')

require './lib/zm/client'

class TestAccount < Minitest::Test

  def setup
    @admin = Zm::Client::Cluster.new(Zm::Client::ClusterConfig.new('./test/fixtures/config.yml'))
    @admin.login

    @fixture_coses = YAML.load(File.read('./test/fixtures/coses.yml'))
  end

  def test_count
    assert @admin.coses.all.count.is_a? Integer
  end

  def test_find
    cos = @admin.coses.find_by name: @fixture_coses['coses']['default']['name']
    assert cos.is_a? Zm::Client::Cos
    assert_equal(@fixture_coses['coses']['default']['name'], cos.name)
  end
end
