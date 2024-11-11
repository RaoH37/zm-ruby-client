require 'minitest/autorun'
require 'yaml'

$LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__) + '/../lib')

require './lib/zm/client'

class TestContact < Minitest::Test

  def setup
    @admin = Zm::Client::Cluster.new(Zm::Client::ClusterConfig.new('./test/fixtures/config.yml'))
    # @admin.logger.debug!
    @admin.login

    @fixture_accounts = YAML.load(File.read('./test/fixtures/accounts.yml'))
    @account = @admin.accounts.find_by name: @fixture_accounts['accounts']['maxime']['email']
    @account.login
  end

  def test_all
    contacts = @account.contacts.all
    assert contacts.is_a?(Array) && contacts.any?
  end

  def test_create
    contact = @account.contacts.new do |ct|
      ct.email = "test@domain.tld"
      ct.firstName = "test"
      ct.lastName = "TEST"
    end
    contact.create!
    assert !contact.id.nil?
  end

  def test_modify
    contact = @account.contacts.all.first

    if contact.nil?
      assert false
      return
    end

    contact.email2 = "test.#{contact.id}@domain.tld"
    assert contact.modify!
  end

  def test_update
    contact = @account.contacts.all.first

    if contact.nil?
      assert false
      return
    end

    assert contact.update!(email3: "test.#{contact.id}@domain.tld")
  end

  def test_delete
    contact = @account.contacts.first

    if contact.nil?
      assert false
      return
    end

    contact.delete!
    assert contact.id.nil?
  end
end
