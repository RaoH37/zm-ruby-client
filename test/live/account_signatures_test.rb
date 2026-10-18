# frozen_string_literal: true

require_relative 'live_helper'

class AccountSignaturesLiveTest < ZmTest::LiveTest
  def create_signature(name = unique_name('signature'), txt: 'Live Test signature', html: nil)
    signature = account.signatures.new do |sig|
      sig.name = name
      sig.txt = txt
      sig.html = html
    end
    signature.create!
    signature
  end

  def find_signature(id)
    account.signatures.all!.find { |sig| sig.id == id }
  end

  def test_create
    name = unique_name('signature')
    signature = create_signature(name)

    refute_nil signature.id
    assert_equal name, find_signature(signature.id).name
  end

  def test_read_text
    signature = create_signature(txt: 'Text signature')
    found = find_signature(signature.id)

    assert_kind_of Zm::Client::Signature, found
    assert_predicate found, :txt?
    assert_equal 'Text signature', found.txt
  end

  def test_read_html
    signature = create_signature(txt: nil, html: '<p>HTML signature</p>')
    found = find_signature(signature.id)

    assert_predicate found, :html?
    assert_equal '<p>HTML signature</p>', found.html
  end

  def test_create_with_existing_name_raises
    signature = create_signature
    duplicate = account.signatures.new do |sig|
      sig.name = signature.name
      sig.txt = 'duplicate'
    end

    assert_raises(Zm::Error::SoapError) { duplicate.create! }
  end

  def test_modify
    signature = create_signature
    signature.txt = 'Live Test signature modified'

    assert signature.modify!
    assert_equal 'Live Test signature modified', find_signature(signature.id).txt
  end

  def test_rename
    signature = create_signature
    new_name = unique_name('renamed')
    signature.rename!(new_name)

    assert_equal new_name, signature.name
    found = find_signature(signature.id)
    assert_equal new_name, found.name
    assert_equal 'Live Test signature', found.txt
  end

  def test_delete
    signature = create_signature
    signature.delete!

    assert_nil find_signature(signature.id)
  end
end
