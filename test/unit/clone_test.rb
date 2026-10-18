# frozen_string_literal: true

require_relative '../test_helper'

class CloneTest < ZmTest::UnitTest
  def setup
    super
    @account = logged_account
  end

  def test_identity_clone_builds_its_own_request
    identity = @account.identities.new do |ident|
      ident.id = '1'
      ident.name = 'orig'
      ident.zimbraPrefIdentityName = 'orig'
      ident.zimbraPrefFromDisplay = 'Display'
      ident.zimbraPrefDefaultSignatureId = 'sig'
    end
    identity.jsns_builder

    copy = identity.clone do |ident|
      ident.name = 'copy'
      ident.zimbraPrefIdentityName = 'copy'
    end
    node = copy.jsns_builder.to_jsns.to_hash.dig('CreateIdentityRequest', 'identity')

    assert_nil copy.id
    assert_equal 'copy', node[:name]
    assert_equal 'copy', node[:_attrs][:zimbraPrefIdentityName]
    assert_equal 'Display', node[:_attrs][:zimbraPrefFromDisplay]
    assert_nil node[:_attrs][:zimbraPrefDefaultSignatureId]
    assert_equal 'orig', identity.jsns_builder.to_jsns.to_hash.dig('CreateIdentityRequest', 'identity', :name)
  end

  def test_clone_does_not_share_collections_of_the_original
    distribution_list = logged_cluster.distribution_lists.new do |dl|
      dl.id = 'dl-1'
      dl.name = 'list@domain.tld'
    end
    distribution_list.members.all = ['member@domain.tld']

    copy = distribution_list.clone

    refute_same distribution_list.members, copy.members
    assert_empty copy.members.all
    assert_equal ['member@domain.tld'], distribution_list.members.all
    assert_same distribution_list.parent, copy.parent
  end

  def test_clone_without_id
    cos = logged_cluster.coses.new { |c| c.name = 'cos' }

    assert_equal 'cos-copy', cos.clone { |c| c.name = 'cos-copy' }.name
  end
end
