require 'minitest/autorun'

$LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__) + '/../lib')

require './lib/zm/client'
require './lib/zm/client/cluster'

class TestAccount < Minitest::Test

  def setup
    @admin = Zm::Client::Cluster.new(Zm::Client::ClusterConfig.new('./test/tmp/example.json'))
    @admin.login
    @cos_name = 'default'
  end

  def test_all
    assert @admin.coses.all.count.is_a? Integer
  end

  def test_find
    cos = @admin.coses.find_by name: @cos_name
    assert_equal(@cos_name, cos.name)
  end
end
