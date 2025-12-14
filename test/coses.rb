require 'minitest/autorun'
require 'yaml'

$LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__) + '/../lib')

require './lib/zm/client'

class TestCoses < Minitest::Test

  def setup
    @admin = Zm::Client::Cluster.new(Zm::Client::ClusterConfig.new('./test/fixtures/config.yml'))
    @admin.login

    @fixture_coses = YAML.load(File.read('./test/fixtures/coses.yml'))
  end

  def test_count
    assert @admin.coses.count.is_a? Integer
  end

  def test_find
    cos = @admin.coses.find_by name: @fixture_coses['coses']['default']['name']
    assert cos.is_a? Zm::Client::Cos
    assert_equal(@fixture_coses['coses']['default']['name'], cos.name)
  end

  def test_create
    cos = @admin.coses.new
    cos.name = "test_cos_#{Time.now.to_i}"
    cos.zimbraMailQuota = 10 * 1024**3
    cos.zimbraFeatureBriefcasesEnabled = 'FALSE'
    cos.zimbraPop3Enabled = 'FALSE'
    cos.zimbraZimletAvailableZimlets = ['!com_zimbra_date', '!com_zimbra_attachcontacts']
    cos.save!

    assert !cos.id.nil?
  end

  def test_modify
    cos = @admin.coses.find_by name: @fixture_coses['coses']['default']['name']
    cos.zimbraMailQuota = 10 * 1024**3
    assert cos.save!
  end

  def test_patch
    cos = @admin.coses.find_by name: @fixture_coses['coses']['default']['name']
    cos.update!({ zimbraMailQuota: 0 })
  end
end
