# frozen_string_literal: true

require_relative 'live_helper'

class CosesLiveTest < ZmTest::LiveTest
  QUOTA = 1024**3

  def create_cos(name = unique_name('cos'))
    cos = cluster.coses.new do |c|
      c.name = name
      c.description = 'Live Test'
      c.zimbraMailQuota = QUOTA
    end
    cos.save!
    track(cos)
  end

  def find_cos(id)
    cluster.coses.attrs('cn', 'description', 'zimbraMailQuota').find_by(id:)
  end

  def test_create
    name = unique_name('cos')
    cos = create_cos(name)

    refute_nil cos.id
    assert_equal name, find_cos(cos.id).name
  end

  def test_read
    cos = create_cos
    found = find_cos(cos.id)

    assert_kind_of Zm::Client::Cos, found
    assert_equal 'Live Test', found.description
    assert_equal QUOTA, found.zimbraMailQuota.to_i
  end

  def test_modify
    cos = create_cos
    cos.zimbraMailQuota = 2 * QUOTA
    cos.save!

    assert_equal 2 * QUOTA, find_cos(cos.id).zimbraMailQuota.to_i
  end

  def test_update
    cos = create_cos

    assert cos.update!(description: 'patched')
    assert_equal 'patched', find_cos(cos.id).description
  end

  def test_clone
    cos = create_cos
    clone_name = unique_name('clone')
    clone_id = cos.clone!(clone_name)
    track(cluster.coses.new { |c| c.id = clone_id })

    assert_equal clone_name, find_cos(clone_id).name
  end

  def test_delete
    cos = create_cos
    id = cos.id
    cos.delete!

    assert_nil cluster.coses.find_by_or_nil(id:)
  end
end
