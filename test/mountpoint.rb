require 'minitest/autorun'
require 'yaml'

$LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__) + '/../lib')

require './lib/zm/client'

class TestMountPoint < Minitest::Test

  def setup
    @admin = Zm::Client::Cluster.new(Zm::Client::ClusterConfig.new('./test/fixtures/config.yml'))
    # @admin.logger.debug!
    @admin.login

    @fixture_accounts = YAML.load(File.read('./test/fixtures/accounts.yml'))
    @account = @admin.accounts.find_by name: @fixture_accounts['accounts']['maxime']['email']
    # @account.login
  end

  def test_all
    mountpoints = @account.mountpoints.all
    assert mountpoints.is_a?(Array) && mountpoints.any?
  end

  def test_clone
    mountpoint = @account.mountpoints.all.sample
    new_mountpoint = mountpoint.clone
    new_mountpoint.name = "Test clone #{Time.now.to_i}"
    new_mountpoint.save!

    assert !new_mountpoint.id.nil?
  end

  def test_color
    mountpoint = @account.mountpoints.first
    mountpoint.color = (1..5).to_a.sample

    begin
      is_modified = mountpoint.color!
    rescue StandardError => _
      is_modified = false
    end

    assert is_modified
  end

  def test_rename
    mountpoint = @account.mountpoints.all.sample
    new_name = "Test #{Time.now.to_i}"
    mountpoint.rename!(new_name)

    mountpoints = @account.mountpoints.all!
    mountpoint2 = mountpoints.find { |f| f.name == new_name }

    assert !mountpoint2.nil?
  end
end
