require "minitest/autorun"
require 'yaml'
require 'securerandom'

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
    dl = @admin.distributionlists.find_by(name: @fixture_dls['dls']['unittest']['name'])
    assert dl.is_a? Zm::Client::DistributionList
    assert dl.name == @fixture_dls['dls']['unittest']['name']
  end

  def test_new_dl
    dl_uid = SecureRandom.alphanumeric(8).downcase
    new_dl_name = "#{dl_uid}@#{@fixture_dls['dls']['unittest']['name'].split('@').last}"

    dl = @admin.distributionlists.new do |new_dl|
      new_dl.name = new_dl_name
      new_dl.description = @fixture_dls['dls']['unittest']['description']
    end

    dl.create!
    assert !dl.id.nil?

    assert dl.members.add!(@fixture_dls['dls']['unittest']['members'])

    dl.delete!
    assert dl.id.nil?
  end

  def test_dl_aliases
    dl = @admin.distributionlists.find_by(name: @fixture_dls['dls']['unittest']['name'])
    assert dl.aliases.all.is_a?(Array)
    assert !dl.aliases.all.include?(dl.name)

    alias_uid = SecureRandom.alphanumeric(8).downcase
    new_alias = "#{alias_uid}@#{dl.name.split('@').last}"

    assert dl.aliases.add!(new_alias)
    assert dl.aliases.remove!(new_alias)
  end
end