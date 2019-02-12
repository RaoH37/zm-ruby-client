require "minitest/autorun"

$LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__) + "/../lib")

require './lib/zimbra_soap_json'
require './lib/zimbra_soap_json/cluster'
include ZimbraSoapJson

class TestAccount < Minitest::Test
  def setup

    @admin = Cluster.new(ClusterConfig.new("./config/renater.json"))
    @admin.login
    
    @account_name = "maxime.zxt@partage.renater.fr"
    @domain_name = @account_name.split('@').last
    
    # @domain = @admin.domains.find_by name: @domain_name
    
    @account = @admin.accounts.find_by name: @account_name
    @account.set_soap_account_connector(@admin.get_soap_account_connector)
    @account.account_login(@admin.get_domain_key(@domain_name))

  end

  def test_all
    assert @account.appointments.all.any?
  end

  def test_where
    assert @account.appointments.where(10, 1543186800000, 1543618799999).any?
  end

end