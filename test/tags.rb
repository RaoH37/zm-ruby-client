require "minitest/autorun"

$LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__) + "/../lib")

require './lib/admin.rb'
include ZimbraSoapJson

class TestAccount < Minitest::Test
  def setup

    @admin = Admin.new("https","zstore10-admin.partage.renater.fr", 7071, "admin@partage.renater.fr", "7qpgFv2dJp")
    @admin.login
    @account = @admin.accounts.find_by name: "maxime.zxt@partage.renater.fr"

  end

  def test_all 
    @account.tags.all.any?
  end

end