require "minitest/autorun"
require 'yaml'

$LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__) + '/../lib')

require './lib/zm/client'

class TestDls < Minitest::Test
  def setup
    @admin = Zm::Client::Cluster.new(Zm::Client::ClusterConfig.new('./test/fixtures/config.yml'))
    @admin.login

    @fixture_dls = YAML.load(File.read('./test/fixtures/dls.yml'))
  end

  def test_all
    dls = @admin.distributionlists.where(@fixture_dls['collections']['where']['default']).all
    assert dls.any?
  end

  def test_find_by_name
    dl = @admin.distributionlists.find_by(name: @fixture_dls['dl']['default']['name'])
    assert dl.is_a? Zm::Client::DistributionList
    assert dl.name == @fixture_dls['dl']['default']['name']
  end

  def test_new_dl
    dl = @admin.distributionlists.new do |new_dl|
      new_dl.name = format(@fixture_dls['dl']['unittest']['name'], Time.now.to_i)
      new_dl.description = @fixture_dls['dl']['unittest']['description']
    end

    puts "create unittest dl: #{dl.name}"

    dl.create!

    dl.members.add!(@fixture_dls['dl']['unittest']['members'])

    assert !dl.id.nil?

    assert dl.delete!
  end

  def test_dl_aliases
    dl = @admin.distributionlists.find_by(name: @fixture_dls['dl']['default']['name'])
    assert dl.aliases.all.is_a?(Array)
    assert !dl.aliases.all.include?(dl.name)

    @fixture_dls['dl']['default']['aliases'].each do |email|
      puts "add alias #{email}"
      dl.aliases.add!(email)
    end

    dl2 = @admin.distributionlists.find_by(name: @fixture_dls['dl']['default']['name'])
    @fixture_dls['dl']['default']['aliases'].each do |email|
      assert dl2.aliases.all.include?(email)
    end

    @fixture_dls['dl']['default']['aliases'].each do |email|
      dl.aliases.remove!(email)
    end
  end
end