# frozen_string_literal: true

require_relative 'live_helper'

class DomainsLiveTest < ZmTest::LiveTest
  def find_domain(id)
    cluster.domains.attrs('description', 'zimbraGalMaxResults').find_by(id:)
  end

  def test_create
    refute_nil domain.id
    assert_equal domain.name, find_domain(domain.id).name
  end

  def test_read
    found = cluster.domains.find_by(name: domain.name)

    assert_kind_of Zm::Client::Domain, found
    assert_equal domain.id, found.id
  end

  def test_modify
    domain.zimbraGalMaxResults = 321
    domain.save!

    assert_equal 321, find_domain(domain.id).zimbraGalMaxResults.to_i
  end

  def test_update
    assert domain.update!(description: 'patched')
    assert_equal 'patched', find_domain(domain.id).description
  end

  def test_delete
    id = domain.id
    domain.delete!

    assert_nil domain.id
    assert_nil cluster.domains.find_by_or_nil(id:)
  end
end
