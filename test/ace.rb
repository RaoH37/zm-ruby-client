require 'minitest/autorun'
require 'yaml'

$LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__) + '/../lib')

require './lib/zm/client'

class TestSearchFolder < Minitest::Test

  def setup
    @admin = Zm::Client::Cluster.new(Zm::Client::ClusterConfig.new('./test/fixtures/config.yml'))
    # @admin.logger.debug!
    @admin.login

    @fixture_accounts = YAML.load(File.read('./test/fixtures/accounts.yml'))
    @account = @admin.accounts.find_by name: @fixture_accounts['accounts']['maxime']['email']
    # @account.login
  end

  def test_all
    aces = @account.aces.all
    assert aces.is_a?(Array)
  end

  def test_where
    aces = @account.aces.where('sendAs', 'sendOnBehalfOf').all
    assert aces.is_a?(Array)
  end

  def test_create
    ace = @account.aces.new do |a|
      a.d = @fixture_accounts['accounts']['maxime']['email']
      a.right = 'sendAs'
      a.gt = 'usr'
    end

    assert ace.save!
  end

  def test_delete
    ace = @account.aces.all.sample
    ace.delete!

    pattern = [ace.right, ace.d].join(':')

    patterns = @account.aces.all!.map { |item| [item.right, item.d].join(':') }

    assert !patterns.include?(pattern)
  end
end
