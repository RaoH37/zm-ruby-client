require "minitest/autorun"

$LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__) + "/../lib")

require './lib/admin.rb'
include ZimbraSoapJson

class TestFolder < Minitest::Test
  def setup

    @admin = Admin.new("https","zstore10-admin.partage.renater.fr", 7071, "admin@partage.renater.fr", "7qpgFv2dJp")
    @admin.login
    
    @account = @admin.accounts.find_by name: "maxime.zxt@partage.renater.fr"
    @account.set_soap_admin_connector(@admin.soap_admin_connector)
    @account.set_soap_account_connector(SoapAccountConnector.new("https","webmail.partage.renater.fr", 443))
    @account.admin_login

  end

  def test_all
    assert @account.folders.all.any?
  end

  def test_where
    assert @account.folders.where(FolderView::MESSAGE).any?
  end

  def test_link
    @account.folders.all!
    assert @account.folders.links.any?
  end

end