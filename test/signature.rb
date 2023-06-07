require 'minitest/autorun'
require 'yaml'

$LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__) + '/../lib')

require './lib/zm/client'

class TestSignature < Minitest::Test

  def setup
    @admin = Zm::Client::Cluster.new(Zm::Client::ClusterConfig.new('./test/fixtures/config.yml'))
    @admin.login

    @fixture_accounts = YAML.load(File.read('./test/fixtures/accounts.yml'))
    @account = @admin.accounts.find_by name: @fixture_accounts['accounts']['maxime']['email']
    @account.login
  end

  def test_all
    signatures = @account.signatures.all
    assert signatures.is_a?(Array)
  end

  def test_create
    signature = @account.signatures.new do |sf|
      sf.name = "test signature #{Time.now.to_i}"
      sf.txt = "ceci est un test de création"
    end
    signature.create!
    assert !signature.id.nil?
  end

  def test_modify
    signature = @account.signatures.first
    signature.txt = "ceci est un test de modification"

    assert signature.modify!
  end

  def test_rename
    signature = @account.signatures.first
    new_name = signature.name + "1"
    signature.rename!(new_name)

    assert @account.signatures.all!.find { |sig| sig.name == new_name }
  end

  def test_delete
    signature = @account.signatures.first
    signature.delete!
    assert signature.id.nil?
  end
end
