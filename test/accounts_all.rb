require 'minitest/autorun'

$LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__) + '/../lib')

require './lib/zm/client'
require 'securerandom'

class TestAccount < Minitest::Test

  def setup
    @config = Zm::Client::ClusterConfig.new('./test/fixtures/config.yml')
    @fixture_accounts = YAML.load(File.read('./test/fixtures/accounts.yml'))

    @admin = Zm::Client::Cluster.new(@config)
    # @admin.logger.debug!
    @admin.login
  end

  def test_mass_update_with_error!
    accounts = @admin.accounts.limit(20).all

    wrong_uuid = SecureRandom.uuid
    accounts.insert(10, wrong_uuid)

    @admin.accounts.mass_update!(
      accounts,
      { description: 'test mass update' },
      update_attributes: false
    )

    wrong_account = accounts.find { |account| account.id == wrong_uuid }
    assert !wrong_account.updated?

    assert accounts.count { |account| !account.updated? } == 1
  end
end
