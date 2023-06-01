require 'minitest/autorun'

$LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__) + '/../lib')

require './lib/zm/client'

class TestDistributionList < Minitest::Test

  def setup
    @config = Zm::Client::ClusterConfig.new('./test/fixtures/config2.yml')
    @fixture_distribution_lists = YAML.load(File.read('./test/fixtures/dls.yml'))

    @admin = Zm::Client::Cluster.new(@config)
    @admin.login
  end

  def test_all
    distribution_lists = @admin.distribution_lists.where(@fixture_distribution_lists['collections']['where']['domain']).all
    assert distribution_lists == @admin.distribution_lists.all
  end

  def test_all_is_distribution_list
    distribution_lists = @admin.distribution_lists.where(@fixture_distribution_lists['collections']['where']['domain']).all
    assert distribution_lists.map(&:class).uniq.first == Zm::Client::DistributionList
  end

  def test_all_where
    distribution_lists = @admin.distribution_lists.where(@fixture_distribution_lists['collections']['where']['domain']).all
    assert distribution_lists != @admin.distribution_lists.where(@fixture_distribution_lists['collections']['where']['disabled']).all!
  end

  def test_all!
    distribution_lists = @admin.distribution_lists.where(@fixture_distribution_lists['collections']['where']['domain']).all
    assert distribution_lists != @admin.distribution_lists.where(@fixture_distribution_lists['collections']['where']['domain']).all!
  end

  def test_where
    assert @admin.distribution_lists.where(@fixture_distribution_lists['collections']['where']['domain']).count.is_a? Integer
  end

  def test_where_chain
    where_clause = @fixture_distribution_lists['collections']['where']['domain']
    order_clause = @fixture_distribution_lists['collections']['order']['default']
    attrs_clause = @fixture_distribution_lists['collections']['attrs']['default']
    assert @admin.distribution_lists.where(where_clause).order(order_clause).attrs(*attrs_clause).all.any?
  end

  def test_find_by_name
    attrs_clause = @fixture_distribution_lists['collections']['attrs']['default']
    distribution_list = @admin.distribution_lists.attrs(*attrs_clause).find_by name: @fixture_distribution_lists['dls']['unittest']['email']
    assert distribution_list.is_a? Zm::Client::DistributionList
    assert_equal @fixture_distribution_lists['dls']['unittest']['email'], distribution_list.name
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
    attrs_clause = @fixture_distribution_lists['collections']['attrs']['default']
    distribution_list = @admin.distribution_lists.attrs(*attrs_clause).find_by name: @fixture_distribution_lists['dls']['unittest']['email']
    assert distribution_list.respond_to?(:zimbraMailHost)
  end

  def test_add_alias
    distribution_list = @admin.distribution_lists.attrs('description').find_by name: @fixture_distribution_lists['dls']['unittest']['email']
    uid, domain_name = distribution_list.name.split('@')
    new_alias = "#{uid}_#{Time.now.to_i}@#{domain_name}"
    assert distribution_list.aliases.add!(new_alias)
  end

  def test_remove_alias
    distribution_list = @admin.distribution_lists.attrs('zimbraMailAlias').find_by name: @fixture_distribution_lists['dls']['unittest']['email']
    distribution_list.aliases.all.each do |email|
      assert distribution_list.aliases.remove!(email)
    end
  end

  def test_add_members
    distribution_list = @admin.distribution_lists.attrs('description').find_by name: @fixture_distribution_lists['dls']['unittest']['email']
    assert distribution_list.members.add!(@fixture_distribution_lists['dls']['unittest']['members'])
  end

  def test_remove_members
    distribution_list = @admin.distribution_lists.attrs('description').find_by name: @fixture_distribution_lists['dls']['unittest']['email']
    assert distribution_list.members.remove!(@fixture_distribution_lists['dls']['unittest']['members'])
  end

  def test_create
    name = @fixture_distribution_lists['dls']['toto']['email']
    dl = find_dl_or_nil(name)
    return unless dl.nil?

    dl = @admin.distribution_lists.new do |acc|
      acc.name = name
      acc.description = "Unit test 123"
    end

    dl.zimbraMailStatus = Zm::Client::SoapConstants::DISABLED

    assert dl.save!
  end

  def test_delete
    name = @fixture_distribution_lists['dls']['toto']['email']
    dl = find_dl_or_nil(name)
    return if dl.nil?

    assert dl.delete!.nil?
  end

  def test_modify
    name = @fixture_distribution_lists['dls']['toto']['email']
    dl = find_dl_or_nil(name)
    return if dl.nil?

    dl.description = "Unit test #{Time.now.to_i}"

    assert dl.save!
  end

  def find_dl_or_nil(name)
    @admin.distribution_lists.find_by name: name
  rescue StandardError
    nil
  end
end
