require 'minitest/autorun'
require 'yaml'

$LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__) + '/../lib')

require './lib/zm/client'

class TestAppointments < Minitest::Test

  def setup
    @admin = Zm::Client::Cluster.new(Zm::Client::ClusterConfig.new('./test/fixtures/config.yml'))
    @admin.logger.debug!
    @admin.login

    @fixture_accounts = YAML.load(File.read('./test/fixtures/accounts.yml'))
    @account = @admin.accounts.find_by name: @fixture_accounts['accounts']['maxime']['email']
    # @account.login
  end

  def test_all
    appos = @account.appointments
                    .folder_ids(10)
                    .start_at(Date.new(Time.now.year, 1, 1))
                    .end_at(Date.new(Time.now.year, 12, 31))
                    .all
    assert appos.is_a?(Array)
  end
end
