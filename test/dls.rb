require 'minitest/autorun'

$LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__) + '/../lib')

require './lib/zm/client'

class TestDistributionList < Minitest::Test

  def setup
    @config = Zm::Client::ClusterConfig.new('./test/fixtures/config.yml')
    @fixture_distribution_lists = YAML.load(File.read('./test/fixtures/dls.yml'))

    @admin = Zm::Client::Cluster.new(@config)
    @admin.login
  end

  def distribution_lists
    @admin.distribution_lists.where(@fixture_distribution_lists['collections']['where']['domain'])
  end

  def test_all
    assert distribution_lists.all.is_a?(Array)
  end

  def test_all_is_distribution_list
    classes = distribution_lists.all.map(&:class).uniq
    assert classes.length == 1
    assert classes.first == Zm::Client::DistributionList
  end

  def test_all_where
    all_distribution_lists = @admin.distribution_lists.all
    assert distribution_lists.all.length < all_distribution_lists.length
  end

  def test_where
    assert distribution_lists.count.is_a? Integer
  end

  def test_where_chain
    order_clause = @fixture_distribution_lists['collections']['order']['default']
    attrs_clause = @fixture_distribution_lists['collections']['attrs']['default']
    assert @admin.distribution_lists.where('(mail=*)').order(order_clause).attrs(*attrs_clause).all.any?
  end

  def test_find_by_name
    attrs_clause = @fixture_distribution_lists['collections']['attrs']['default']
    name = distribution_lists.all.sample&.name
    return if name.nil?
    distribution_list = @admin.distribution_lists.attrs(*attrs_clause).find_by name: name
    assert distribution_list.is_a? Zm::Client::DistributionList
  end

  def test_new_distribution_list
    name = @fixture_distribution_lists['dls']['toto']['email']
    distribution_list = @admin.distribution_lists.new do |acc|
      acc.name = name
    end
    assert distribution_list.is_a? Zm::Client::DistributionList
    assert distribution_list.name == name
  end

  def test_attrs
    name = distribution_lists.all.sample&.name
    return if name.nil?
    attrs_clause = @fixture_distribution_lists['collections']['attrs']['default']
    distribution_list = @admin.distribution_lists.attrs(*attrs_clause).find_by name: name
    assert distribution_list.respond_to?(:zimbraMailHost)
  end

  def test_add_alias
    name = distribution_lists.all.sample&.name
    return if name.nil?
    distribution_list = @admin.distribution_lists.attrs('description').find_by name: name
    uid, domain_name = distribution_list.name.split('@')
    new_alias = "#{uid}_#{Time.now.to_i}@#{domain_name}"
    assert distribution_list.aliases.add!(new_alias)
  end

  def test_remove_alias
    name = distribution_lists.all.sample&.name
    return if name.nil?
    distribution_list = @admin.distribution_lists.attrs('zimbraMailAlias').find_by name: name
    distribution_list.aliases.all.each do |email|
      assert distribution_list.aliases.remove!(email)
    end
  end

  def test_add_members
    name = distribution_lists.all.sample&.name
    return if name.nil?
    distribution_list = @admin.distribution_lists.attrs('description').find_by name: name
    assert distribution_list.members.add!(@fixture_distribution_lists['dls']['unittest']['members'])
  end

  def test_remove_members
    name = distribution_lists.all.sample&.name
    return if name.nil?
    distribution_list = @admin.distribution_lists.attrs('description').find_by name: name
    assert distribution_list.members.remove!(@fixture_distribution_lists['dls']['unittest']['members'])
  end

  def test_create
    dl = @admin.distribution_lists.new do |acc|
      acc.name = "dl_#{Time.now.to_i}@#{@fixture_distribution_lists['dls']['unittest']['domain']}"
      acc.description = "Unit test 123"
    end

    dl.zimbraMailStatus = Zm::Client::SoapConstants::DISABLED

    assert dl.save!
  end

  def test_delete
    dl = distribution_lists.all.sample

    dl.delete!
    assert true
  end

  def test_modify
    dl = distribution_lists.all.sample

    dl.description = "Unit test #{Time.now.to_i}"

    assert dl.save!
  end
end
