require "minitest/autorun"

$LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__) + "/../lib")

require './lib/admin.rb'
include ZimbraSoapJson

class TestServer < Minitest::Test
  def setup

    @admin = Admin.new("https","zstore10-admin.partage.renater.fr", 7071, "admin@partage.renater.fr", "7qpgFv2dJp")
    @admin.login

  end

  def test_all
    assert @admin.servers.all.any?
  end

  def test_mailstore
    assert @admin.servers.where(ServerServices::MAILBOX).any?
  end

end