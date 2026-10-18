# frozen_string_literal: true

require_relative 'live_helper'

class AccountIdentitiesLiveTest < ZmTest::LiveTest
  DEFAULT_IDENTITY_NAME = 'DEFAULT'

  def create_identity(name = unique_name('identity'), **attrs)
    identity = account.identities.new do |ident|
      ident.name = name
      ident.zimbraPrefIdentityName = name
      ident.zimbraPrefFromDisplay = 'Live Test'
      ident.zimbraPrefFromAddress = account.name
      ident.zimbraPrefFromAddressType = 'sendAs'
      ident.zimbraPrefReplyToEnabled = 'FALSE'
      ident.zimbraPrefWhenSentToEnabled = 'FALSE'
      ident.zimbraPrefWhenInFoldersEnabled = 'FALSE'
      attrs.each { |key, value| ident.public_send(:"#{key}=", value) }
    end
    identity.create!
    identity
  end

  def create_signature
    signature = account.signatures.new do |sig|
      sig.name = unique_name('signature')
      sig.txt = 'Live Test signature'
    end
    signature.create!
    signature
  end

  def find_identity(id)
    account.identities.all!.find { |ident| ident.id == id }
  end

  def default_identity
    account.identities.all!.find { |ident| ident.name == DEFAULT_IDENTITY_NAME }
  end

  def test_default_identity
    identity = default_identity

    refute_nil identity
    assert_equal account.name, identity.zimbraPrefFromAddress
  end

  def test_create
    name = unique_name('identity')
    identity = create_identity(name)

    refute_nil identity.id
    assert_equal name, find_identity(identity.id).name
  end

  def test_read
    identity = create_identity
    found = find_identity(identity.id)

    assert_kind_of Zm::Client::Identity, found
    assert_equal 'Live Test', found.zimbraPrefFromDisplay
    assert_equal account.name, found.zimbraPrefFromAddress
    assert_equal 'sendAs', found.zimbraPrefFromAddressType
  end

  def test_create_with_reply_to
    identity = create_identity(zimbraPrefReplyToEnabled: 'TRUE',
                               zimbraPrefReplyToDisplay: 'Reply Live Test',
                               zimbraPrefReplyToAddress: 'reply@example.com')
    found = find_identity(identity.id)

    assert_equal 'TRUE', found.zimbraPrefReplyToEnabled
    assert_equal 'Reply Live Test', found.zimbraPrefReplyToDisplay
    assert_equal 'reply@example.com', found.zimbraPrefReplyToAddress
  end

  def test_create_with_signatures
    signature = create_signature
    identity = create_identity(zimbraPrefDefaultSignatureId: signature.id,
                               zimbraPrefForwardReplySignatureId: signature.id)
    found = find_identity(identity.id)

    assert_equal signature.id, found.zimbraPrefDefaultSignatureId
    assert_equal signature.id, found.zimbraPrefForwardReplySignatureId
  end

  def test_create_with_existing_name_raises
    identity = create_identity

    assert_raises(Zm::Error::SoapError) { create_identity(identity.name) }
  end

  def test_modify
    identity = find_identity(create_identity.id)
    identity.zimbraPrefFromDisplay = 'Live Test modified'

    assert identity.modify!
    assert_equal 'Live Test modified', find_identity(identity.id).zimbraPrefFromDisplay
  end

  def test_update
    identity = create_identity

    assert identity.update!({ zimbraPrefFromDisplay: 'patched' })
    assert_equal 'patched', identity.zimbraPrefFromDisplay
    assert_equal 'patched', find_identity(identity.id).zimbraPrefFromDisplay
  end

  def test_update_identity_name
    identity = create_identity
    new_name = unique_name('renamed')

    assert identity.update!({ zimbraPrefIdentityName: new_name })
    assert_equal new_name, find_identity(identity.id).name
  end

  def test_clone
    signature = create_signature
    identity = create_identity(zimbraPrefDefaultSignatureId: signature.id)
    clone_name = unique_name('clone')
    copy = identity.clone do |ident|
      ident.name = clone_name
      ident.zimbraPrefIdentityName = clone_name
    end
    copy.create!

    refute_equal identity.id, copy.id
    found = find_identity(copy.id)
    assert_equal clone_name, found.name
    assert_equal 'Live Test', found.zimbraPrefFromDisplay
    assert_nil found.zimbraPrefDefaultSignatureId
  end

  def test_delete
    identity = create_identity
    identity.delete!

    assert_nil find_identity(identity.id)
  end

  def test_delete_default_identity_raises
    assert_raises(Zm::Error::SoapError) { default_identity.delete! }
  end
end
