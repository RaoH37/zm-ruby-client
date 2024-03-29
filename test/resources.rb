require 'minitest/autorun'

$LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__) + '/../lib')

require './lib/zm/client'

class TestResource < Minitest::Test

  def setup
    @config = Zm::Client::ClusterConfig.new('./test/fixtures/config2.yml')
    @fixture_resources = YAML.load(File.read('./test/fixtures/resources.yml'))

    @admin = Zm::Client::Cluster.new(@config)
    @admin.login
  end

  def test_all
    resources = @admin.resources.where(@fixture_resources['collections']['where']['domain']).all
    assert resources == @admin.resources.all
  end

  def test_all_is_resource
    resources = @admin.resources.where(@fixture_resources['collections']['where']['domain']).all
    assert resources.map(&:class).uniq.first == Zm::Client::Resource
  end

  def test_all_where
    resources = @admin.resources.where(@fixture_resources['collections']['where']['domain']).all
    assert resources != @admin.resources.where(@fixture_resources['collections']['where']['domain_active']).all
  end

  def test_all!
    resources = @admin.resources.where(@fixture_resources['collections']['where']['domain']).all
    assert resources != @admin.resources.where(@fixture_resources['collections']['where']['domain']).all!
  end

  def test_where
    assert @admin.resources.where(@fixture_resources['collections']['where']['domain']).count.is_a? Integer
  end

  def test_where_chain
    where_clause = @fixture_resources['collections']['where']['domain']
    order_clause = @fixture_resources['collections']['order']['default']
    attrs_clause = @fixture_resources['collections']['attrs']['default']
    assert @admin.resources.where(where_clause).order(order_clause).attrs(*attrs_clause).all.any?
  end

  def test_find_by_name
    resource = @admin.resources.attrs('zimbraMailQuota').find_by name: @fixture_resources['resources']['unittest']['email']
    assert resource.is_a? Zm::Client::Resource
    assert_equal @fixture_resources['resources']['unittest']['email'], resource.name
  end

  def test_new_resource
    name = @fixture_resources['resources']['toto']['email']
    resource = @admin.resources.new do |acc|
      acc.name = name
    end
    assert resource.is_a? Zm::Client::Resource
    assert resource.name == name
  end

  def test_attrs
    resource = @admin.resources.attrs('displayName').find_by name: @fixture_resources['resources']['unittest']['email']
    assert resource.respond_to?(:displayName)
  end

  def test_create
    domain_name = @fixture_resources['resources']['toto']['email'].split('@').last
    resource = @admin.resources.new do |acc|
      acc.name = "test.res.#{Time.now.to_i}@#{domain_name}"
      acc.displayName = "Unit Test"
      acc.zimbraCalResType = Zm::Client::Resource::TYPES.sample
    end
    assert resource.save!
  end
end
