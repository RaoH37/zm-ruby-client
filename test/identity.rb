require 'minitest/autorun'
require 'yaml'

$LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__) + '/../lib')

require './lib/zm/client'

class TestIdentity < Minitest::Test
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
    assert @account.identities.all.is_a?(Array)
  end

  def test_all_any
    assert @account.identities.all.any?
  end

  def test_create
    name = "Unit Test #{Time.now.to_i}"

    identity = @account.identities.new do |ident|
      ident.name = name
      ident.zimbraPrefIdentityName = name
      ident.zimbraPrefFromDisplay = 'Unit Test'
      ident.zimbraPrefFromAddress = @account.name
      ident.zimbraPrefFromAddressType = 'sendAs'
      ident.zimbraPrefReplyToEnabled = 'FALSE'
      ident.zimbraPrefWhenSentToEnabled = 'FALSE'
      ident.zimbraPrefWhenInFoldersEnabled = 'FALSE'
    end

    identity.create!

    assert !identity.id.nil?
  end

  def test_modify
    identity = @account.identities.all.reject { |ident| ident.name == 'DEFAULT' }.last

    if identity.nil?
      assert false
      return
    end

    identity.zimbraPrefFromDisplay = "Unit Test Modify #{Time.now.to_i}"

    assert identity.modify!
  end

  def test_patch
    identity = @account.identities.all.reject { |ident| ident.name == 'DEFAULT' }.last

    if identity.nil?
      assert false
      return
    end

    assert identity.update!({ zimbraPrefFromDisplay: "Unit Test Patch #{Time.now.to_i}" })
  end

  def test_delete
    identity = @account.identities.all.reject { |ident| ident.name == 'DEFAULT' }.last

    if identity.nil?
      assert false
      return
    end

    assert identity.delete!.nil?
  end
end