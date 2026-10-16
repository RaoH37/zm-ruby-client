# frozen_string_literal: true

require_relative 'integration_helper'

class DataSourcesIntegrationTest < ZmTest::IntegrationTest

  def setup
    @admin = Zm::Client::Cluster.new(Zm::Client::ClusterConfig.new('./test/fixtures/config.yml'))
    # @admin.logger.debug!
    @admin.login

    @fixture_accounts = YAML.load(File.read('./test/fixtures/accounts.yml'))
    @account = @admin.accounts.find_by name: @fixture_accounts['accounts']['maxime']['email']
    @account.login
  end

  def test_all
    data_sources = @account.data_sources.all
    assert data_sources.is_a?(Array)
  end

  def test_update
    ds = @account.data_sources.all.first

    if ds.nil?
      assert false
      return
    end

    assert ds.update!(pollingInterval: '24h')
  end

  def test_delete
    ds = @account.data_sources.all.first

    if ds.nil?
      assert false
      return
    end

    ds.delete!
    assert true
  end
end
