require "minitest/autorun"

$LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__) + '/../lib')

require './lib/zm/client'
require './lib/zm/client/cluster'

class TestDomain < Minitest::Test
  def setup
    @admin = Zm::Client::Cluster.new(Zm::Client::ClusterConfig.new('./test/tmp/example.json'))
    @admin.login
  end

  # COLLECTION

  def test_all
    assert @admin.domains.all.any?
  end

  # COUNT

  def test_count
    assert @admin.domains.count.is_a? Integer
  end

  def test_count_where_chain
    assert @admin.domains.where('zimbraDomainStatus=active').count.is_a? Integer
  end

  def test_count_limited
    assert_equal @admin.domains.per_page(10).count, 10
  end

  # OBJECT

  def test_find_by_id
    assert @admin.domains.find('25b0a31a-cde7-46cc-9c50-64aa31698b38').is_a? Zm::Client::Domain
  end

  def test_first
    assert @admin.domains.where('zimbraDomainStatus=active').first.is_a? Zm::Client::Domain
  end

end