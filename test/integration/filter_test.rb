# frozen_string_literal: true

require_relative 'integration_helper'

class FilterIntegrationTest < ZmTest::IntegrationTest
  def setup
    @admin = Zm::Client::Cluster.new(Zm::Client::ClusterConfig.new('./test/fixtures/config.yml'))
    # @admin.login

    @fixture_accounts = YAML.load(File.read('./test/fixtures/accounts.yml'))

    @account = @admin.accounts.new
    @account.name = @fixture_accounts['accounts']['maxime']['email']
    @account.domain_key = @fixture_accounts['accounts']['maxime']['domain_key']
    @account.account_login_preauth
  end

  def test_all
    assert @account.filter_rules.all.is_a?(Array)
    assert @account.outgoing_filter_rules.all.is_a?(Array)
  end
end