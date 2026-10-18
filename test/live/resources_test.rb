# frozen_string_literal: true

require_relative 'live_helper'

class ResourcesLiveTest < ZmTest::LiveTest
  def create_resource(name = unique_email('res'), type: Zm::Client::Resource::LOCATION)
    resource = cluster.resources.new do |res|
      res.name = name
      res.displayName = 'Live Test Room'
      res.zimbraCalResType = type
    end
    resource.save!
    track(resource)
  end

  def find_resource(id)
    cluster.resources.attrs('displayName', 'description', 'zimbraCalResType').find_by(id:)
  end

  def test_create
    name = unique_email('res')
    resource = create_resource(name)

    refute_nil resource.id
    assert_equal name, find_resource(resource.id).name
  end

  def test_read
    resource = create_resource(type: Zm::Client::Resource::EQUIPMENT)
    found = find_resource(resource.id)

    assert_kind_of Zm::Client::Resource, found
    assert_equal 'Live Test Room', found.displayName
    assert_predicate found, :equipment?
  end

  def test_modify
    resource = create_resource
    resource.displayName = 'Live Test Room modified'
    resource.save!

    assert_equal 'Live Test Room modified', find_resource(resource.id).displayName
  end

  def test_update
    resource = create_resource

    assert resource.update!(description: 'patched')
    assert_equal 'patched', find_resource(resource.id).description
  end

  def test_delete
    resource = create_resource
    id = resource.id
    resource.delete!

    assert_nil resource.id
    assert_nil cluster.resources.find_by_or_nil(id:)
  end
end
