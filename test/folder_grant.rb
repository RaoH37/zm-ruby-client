require 'minitest/autorun'
require 'yaml'

$LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__) + '/../lib')

require './lib/zm/client'

class TestFolderGrant < Minitest::Test

  def setup
    @admin = Zm::Client::Cluster.new(Zm::Client::ClusterConfig.new('./test/fixtures/config.yml'))
    @admin.login

    @fixture_accounts = YAML.load(File.read('./test/fixtures/accounts.yml'))
    @account = @admin.accounts.find_by name: @fixture_accounts['accounts']['maxime']['email']
    @account.login
  end

  def test_all
    folders_with_grants = @account.folders.all.reject { |f| f.grants.all.empty? }
    folders_with_grants.each do |folder|
      assert folder.grants.all.is_a?(Array)

      folder.grants.all.each do |grant|
        assert grant.is_a?(Zm::Client::FolderGrant)
      end
    end
  end

  def test_delete
    folders_with_grants = @account.folders.all.reject { |f| f.grants.all.empty? }
    folders_with_grants.each do |folder|
      folder.grants.all.each do |grant|
        if grant.is_external? || grant.is_dom?
          grant.delete!
          assert !folder.grants.all.include?(grant)
        end
      end
    end
  end

  def test_create
    folder = @account.folders.all.select { |f| f.grants.all.empty? }.sample
    grant = folder.grants.new(@fixture_accounts['accounts']['unittest']['id'], 'usr', 'r', @fixture_accounts['accounts']['unittest']['email'])
    grant.save!

    folder_ids_with_grants = @account.folders.all.reject { |f| f.grants.all.empty? }.map(&:id)
    assert folder_ids_with_grants.include?(folder.id)
  end
end
