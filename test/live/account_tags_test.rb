# frozen_string_literal: true

require_relative 'live_helper'

class AccountTagsLiveTest < ZmTest::LiveTest
  def create_tag(name = unique_name('tag'), color: 4)
    tag = account.tags.new do |t|
      t.name = name
      t.color = color
    end
    tag.create!
    tag
  end

  def find_tag(id)
    account.tags.all!.find { |t| t.id.to_s == id.to_s }
  end

  def test_create
    name = unique_name('tag')
    tag = create_tag(name)

    refute_nil tag.id
    assert_equal name, find_tag(tag.id).name
  end

  def test_read
    tag = create_tag(color: 2)
    found = find_tag(tag.id)

    assert_kind_of Zm::Client::Tag, found
    assert_equal 2, found.color.to_i
  end

  def test_create_with_existing_name_raises
    tag = create_tag
    duplicate = account.tags.new { |t| t.name = tag.name }

    assert_raises(Zm::Error::SoapError) { duplicate.create! }
  end

  def test_modify
    tag = create_tag(color: 1)
    tag.color = 5

    assert tag.modify!
    assert_equal 5, find_tag(tag.id).color.to_i
  end

  def test_update
    tag = create_tag(color: 1)

    assert tag.update!({ color: 3 })
    assert_equal 3, find_tag(tag.id).color.to_i
  end

  def test_rename
    tag = create_tag
    new_name = unique_name('renamed')
    tag.rename!(new_name)

    assert_equal new_name, find_tag(tag.id).name
  end

  def test_delete
    tag = create_tag
    tag.delete!

    assert_nil find_tag(tag.id)
  end
end
