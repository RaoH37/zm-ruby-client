require 'minitest/autorun'
require 'yaml'

$LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__) + '/../lib')

require './lib/zm/client'

class TestAccount < Minitest::Test

  def setup
    @admin = Zm::Client::Cluster.new(Zm::Client::ClusterConfig.new('./test/fixtures/config.yml'))
    @admin.login

    @fixture_accounts = YAML.load(File.read('./test/fixtures/accounts.yml'))

    @zm_account_attrs = %w[
      sn
      company
      cn
      co
      street
      l
      givenName
      postalAddress
      postalCode
      displayName
      telephoneNumber
      description
      zimbraPrefGroupMailBy
      zimbraPrefFromDisplay
      zimbraPrefFromDisplay
      zimbraPrefMailSignature
      zimbraPrefMailSignatureHTML
      zimbraPrefMailSignatureStyle
      zimbraPrefDefaultSignatureId
      zimbraPrefForwardReplySignatureId
      zimbraPrefReplyToEnabled
      zimbraPrefIdentityName
      zimbraPrefFromAddress
      zimbraPrefWhenInFoldersEnabled
      zimbraPrefWhenSentToEnabled
      zimbraPrefSortOrder
      zimbraSignatureName
      userPassword
      zimbraPasswordMustChange
      zimbraPrefOutOfOfficeFromDate
      zimbraPrefOutOfOfficeReplyEnabled
      zimbraPrefOutOfOfficeUntilDate
      zimbraPrefOutOfOfficeReply
      zimbraAccountStatus
      zimbraMailStatus
      zimbraPasswordMustChange
      zimbraPrefSortOrder
      zimbraMailSieveScript
      zimbraPrefTasksReadingPaneLocation
      zimbraPrefShowCalendarWeek
      zimbraPrefForwardIncludeOriginalText
      zimbraPrefReplyIncludeOriginalText
      zimbraPrefHtmlEditorDefaultFontFamily
      zimbraPrefZimletTreeOpen
      zimbraPrefComposeFormat
      zimbraPrefFolderTreeOpen
      zimbraPrefCalendarFirstDayOfWeek
      zimbraPrefCalendarForwardInvitesTo
      zimbraPrefMailForwardingAddress
      zimbraMailDeliveryAddress
      zimbraCOSId
    ]
  end

  def test_find_by_name
    account = @admin.accounts.find_by name: @fixture_accounts['accounts']['maxime']['email']
    assert account.is_a? Zm::Client::Account
    assert_equal @fixture_accounts['accounts']['maxime']['email'], account.name
  end

  def test_zcs_attributes
    account = @admin.accounts.attrs(@zm_account_attrs).find_by name: @fixture_accounts['accounts']['maxime']['email']
    @zm_account_attrs.each do |attr|
      assert account.respond_to?(attr)
    end
  end

  def test_zcs_attributes_set
    account = @admin.accounts.attrs(@zm_account_attrs).find_by name: @fixture_accounts['accounts']['maxime']['email']
    description = account.send(:description)
    assert !description.nil?
  end

  def test_create_account
    account = @admin.accounts.new
    account.name = @fixture_accounts['accounts']['unittest']['email']
    account.description = @fixture_accounts['accounts']['unittest']['description']
    account.create!

    assert !account.id.nil?

    unittest = @admin.accounts.attrs('description').find_by name: @fixture_accounts['accounts']['unittest']['email']
    assert unittest.description == @fixture_accounts['accounts']['unittest']['description']

    unittest.delete!
  end

  def test_modify_account
    account = @admin.accounts.attrs('description').find_by name: @fixture_accounts['accounts']['maxime']['email']
    new_description = "new description #{Time.now.to_f}"
    puts "new_description = #{new_description}"
    account.description = new_description
    puts "account.description = #{account.description}"
    account.modify!

    unittest = @admin.accounts.attrs('description').find_by name: @fixture_accounts['accounts']['maxime']['email']
    puts "unittest.description = #{unittest.description}"

    assert unittest.description == new_description
  end

  def test_update_account
    account = @admin.accounts.attrs('description').find_by name: @fixture_accounts['accounts']['maxime']['email']
    new_description = "new description #{Time.now.to_f}"
    puts "new_description = #{new_description}"
    account.update!({ description: new_description })

    assert account.description == new_description

    unittest = @admin.accounts.attrs('description').find_by name: @fixture_accounts['accounts']['maxime']['email']
    puts "unittest.description = #{unittest.description}"

    assert unittest.description == new_description
  end

  def test_token_nil
    account = @admin.accounts.new
    assert account.token.nil?
  end

  def test_admin_login
    account = @admin.accounts.new
    account.name = @fixture_accounts['accounts']['maxime']['email']
    account.admin_login

    assert !account.token.nil?
  end

  def test_preauth_login
    account = @admin.accounts.new
    account.name = @fixture_accounts['accounts']['maxime']['email']
    account.account_login_preauth

    assert !account.token.nil?
  end
end
