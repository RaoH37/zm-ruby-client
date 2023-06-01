require "minitest/autorun"
require 'yaml'

$LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__) + '/../lib')

require './lib/zm/client'

class TestDomain < Minitest::Test
  def setup
    @admin = Zm::Client::Cluster.new(Zm::Client::ClusterConfig.new('./test/fixtures/config2.yml'))
    @admin.login

    @fixture_domains = YAML.load(File.read('./test/fixtures/domains.yml'))
  end

  def test_all
    domains = @admin.domains.where(@fixture_domains['collections']['where']['local']).all
    assert domains == @admin.domains.all
  end

  def test_all_is_domain
    domains = @admin.domains.where(@fixture_domains['collections']['where']['local']).all
    assert domains.map(&:class).uniq.first == Zm::Client::Domain
  end

  def test_all_where
    domains = @admin.domains.where(@fixture_domains['collections']['where']['local']).all
    assert domains != @admin.domains.where(@fixture_domains['collections']['where']['alias']).all
  end

  def test_all!
    domains = @admin.domains.where(@fixture_domains['collections']['where']['local']).all
    assert domains != @admin.domains.where(@fixture_domains['collections']['where']['local']).all!
  end

  def test_where
    assert @admin.domains.where(@fixture_domains['collections']['where']['local']).count.is_a? Integer
  end

  def test_where_chain
    where_clause = @fixture_domains['collections']['where']['local']
    order_clause = @fixture_domains['collections']['order']['default']
    attrs_clause = @fixture_domains['collections']['attrs']['default']
    assert @admin.domains.where(where_clause).order(order_clause).attrs(*attrs_clause).all.any?
  end

  def test_find_by_name
    domain = @admin.domains.find_by name: @fixture_domains['domains']['default']['name']
    assert domain.is_a? Zm::Client::Domain
    assert_equal @fixture_domains['domains']['default']['name'], domain.name
  end

  def test_find_by_name_with_attrs
    domain = @admin.domains.attrs('zimbraPreAuthKey', 'description', 'zimbraACE').find_by name: @fixture_domains['domains']['default']['name']
    assert domain.is_a? Zm::Client::Domain
    assert_equal @fixture_domains['domains']['default']['name'], domain.name
  end

  def test_new_domain
    name = @fixture_domains['domains']['toto']['name']
    domain = @admin.domains.new do |acc|
      acc.name = name
    end
    assert domain.is_a? Zm::Client::Domain
    assert domain.name == name
  end

  def test_create
    name = @fixture_domains['domains']['toto']['name']
    domain = find_domain_or_nil(name)
    return unless domain.nil?

    domain = @admin.domains.new do |acc|
      acc.name = name
    end

    domain.save!

    assert !domain.id.nil?
  end

  def test_delete
    domain = find_domain_or_nil(@fixture_domains['domains']['toto']['name'])
    return if domain.nil?

    assert domain.delete!.nil?
  end

  def test_modify
    domain = find_domain_or_nil(@fixture_domains['domains']['toto']['name'])
    return if domain.nil?

    domain.zimbraGalMaxResults = rand(100..1000)

    assert domain.modify!
  end

  def find_domain_or_nil(name)
    @admin.domains.find_by name: name
  rescue StandardError => e
    nil
  end
end