require "minitest/autorun"

$LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__) + "/../lib")

require './lib/admin.rb'
include ZimbraSoapJson

class TestMessage < Minitest::Test
  
  def setup

    @admin = Admin.new("https","zstore10-admin.partage.renater.fr", 7071, "admin@partage.renater.fr", "7qpgFv2dJp")
    @admin.login
    
    @account = @admin.accounts.find_by name: "maxime.zxt@partage.renater.fr"
    @account.set_soap_account_connector(SoapAccountConnector.new("https","webmail.partage.renater.fr", 443))
    @account.admin_login

  end

  def test_count_all
    @account.folders.where! FolderView::MESSAGE
    refute @account.folders.folders.map{|f|f.nb_messages}.inject(:+).zero?
  end

end