# frozen_string_literal: true

require_relative '../test_helper'

class DistributionListTest < ZmTest::UnitTest
  def setup
    super
    @dl = logged_cluster.distribution_lists.new do |dl|
      dl.id = 'dl-id'
      dl.name = 'list@domain.tld'
    end
  end

  def test_members_add_accepts_frozen_emails_and_normalizes_them
    @fake.on(:AddDistributionListMemberRequest, { AddDistributionListMemberResponse: {} })
    emails = [' John@Domain.tld ', 'jane@domain.tld', 'JANE@domain.tld']

    assert @dl.members.add!(emails)

    request = @fake.last_request(:AddDistributionListMemberRequest)
    assert_equal [{ _content: 'john@domain.tld' }, { _content: 'jane@domain.tld' }], request.body[:dlm]
    assert_equal %w[john@domain.tld jane@domain.tld], @dl.members.all
    assert_equal ' John@Domain.tld ', emails.first
  end

  def test_members_add_skips_existing_members
    @dl.members.all = ['john@domain.tld']

    refute @dl.members.add!('John@domain.tld')
    assert_empty(@fake.requests.select { |r| r.name == 'AddDistributionListMemberRequest' })
  end

  def test_members_remove_only_known_members
    @fake.on(:RemoveDistributionListMemberRequest, { RemoveDistributionListMemberResponse: {} })
    @dl.members.all = ['john@domain.tld', 'jane@domain.tld']

    assert @dl.members.remove!(['JOHN@domain.tld', 'unknown@domain.tld'])

    assert_equal [{ _content: 'john@domain.tld' }], @fake.last_request(:RemoveDistributionListMemberRequest).body[:dlm]
    assert_equal ['jane@domain.tld'], @dl.members.all
  end

  def test_owners_add_accepts_frozen_emails
    @fake.on(:DistributionListActionRequest, { DistributionListActionResponse: {} })

    assert @dl.owners.add!('Owner@Domain.tld')

    owners = @fake.last_request(:DistributionListActionRequest).body.dig(:action, :owner)
    assert_equal [{ by: 'name', type: 'usr', _content: 'owner@domain.tld' }], owners
    assert_equal ['owner@domain.tld'], @dl.owners.all
  end

  def test_aliases_add_normalizes_frozen_email
    @fake.on(:AddDistributionListAliasRequest, { AddDistributionListAliasResponse: {} })

    assert @dl.aliases.add!(' Alias@Domain.tld')

    assert_equal 'alias@domain.tld', @fake.last_request(:AddDistributionListAliasRequest).body[:alias]
    assert_includes @dl.aliases.all, 'alias@domain.tld'
  end

  def test_members_add_with_nil_raises_before_any_request
    assert_raises(ArgumentError) { @dl.members.add!(['john@domain.tld', nil]) }
    assert_raises(ArgumentError) { @dl.aliases.add!(nil) }
    assert_empty(@fake.requests.reject { |r| r.name == 'AuthRequest' })
  end
end
