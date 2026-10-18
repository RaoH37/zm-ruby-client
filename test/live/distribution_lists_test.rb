# frozen_string_literal: true

require_relative 'live_helper'

class DistributionListsLiveTest < ZmTest::LiveTest
  def create_distribution_list(name = unique_email('dl'))
    distribution_list = cluster.distribution_lists.new do |dl|
      dl.name = name
      dl.description = 'Live Test'
    end
    distribution_list.save!
    track(distribution_list)
  end

  def find_distribution_list(id)
    cluster.distribution_lists.attrs('description', 'zimbraMailAlias').find_by(id:)
  end

  def test_create
    name = unique_email('dl')
    distribution_list = create_distribution_list(name)

    refute_nil distribution_list.id
    assert_equal name, find_distribution_list(distribution_list.id).name
  end

  def test_read
    distribution_list = create_distribution_list
    found = find_distribution_list(distribution_list.id)

    assert_kind_of Zm::Client::DistributionList, found
    assert_equal 'Live Test', found.description
  end

  def test_modify
    distribution_list = create_distribution_list
    distribution_list.description = 'Live Test modified'
    distribution_list.save!

    assert_equal 'Live Test modified', find_distribution_list(distribution_list.id).description
  end

  def test_update
    distribution_list = create_distribution_list

    assert distribution_list.update!(description: 'patched')
    assert_equal 'patched', find_distribution_list(distribution_list.id).description
  end

  def test_rename
    distribution_list = create_distribution_list
    new_name = unique_email('renamed')
    distribution_list.rename!(new_name)

    assert_equal new_name, find_distribution_list(distribution_list.id).name
  end

  def test_members
    distribution_list = create_distribution_list
    members = [unique_email('member'), unique_email('member')]

    assert distribution_list.members.add!(members)
    assert_equal members.sort, find_distribution_list(distribution_list.id).members.all.sort

    assert distribution_list.members.remove!(members.first)
    assert_equal [members.last], find_distribution_list(distribution_list.id).members.all
  end

  def test_aliases
    distribution_list = create_distribution_list
    alias_name = unique_email('alias')

    assert distribution_list.aliases.add!(alias_name)
    assert_includes find_distribution_list(distribution_list.id).aliases.all, alias_name

    assert distribution_list.aliases.remove!(alias_name)
    refute_includes find_distribution_list(distribution_list.id).aliases.all, alias_name
  end

  def test_delete
    distribution_list = create_distribution_list
    id = distribution_list.id
    distribution_list.delete!

    assert_nil distribution_list.id
    assert_nil cluster.distribution_lists.find_by_or_nil(id:)
  end
end
