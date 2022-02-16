require 'minitest/autorun'
require 'yaml'

$LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__) + '/../lib')

require './lib/zm/client'

class TestRetentionPolicy < Minitest::Test

  def setup
    @admin = Zm::Client::Cluster.new(Zm::Client::ClusterConfig.new('./test/fixtures/config.yml'))
    # @admin.logger.debug!
    @admin.login

    @fixture_accounts = YAML.load(File.read('./test/fixtures/accounts.yml'))
    @account = @admin.accounts.find_by name: @fixture_accounts['accounts']['maxime']['email']
    @account.login
  end

  def test_all
    folders_with_retention_policies = @account.folders.all.reject { |f| f.retention_policies.all.empty? }
    folders_with_retention_policies.each do |folder|
      assert folder.retention_policies.all.is_a?(Array)
    end
  end

  def test_update
    lifetime = "#{(1..300).to_a.sample}d"
    folder = @account.folders.all.reject { |f| f.retention_policies.all.empty? }.sample
    folder.retention_policies.all.each do |rp|
      rp.lifetime = lifetime
    end
    folder.retention_policies.save!

    folder2 = @account.folders.all!.find { |f| f.id == folder.id }
    folder2.retention_policies.all.each do |rp|
      assert rp.lifetime == lifetime
    end
  end
end
