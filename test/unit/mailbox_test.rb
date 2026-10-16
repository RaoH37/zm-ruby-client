# frozen_string_literal: true

require_relative '../test_helper'

class MailboxTest < ZmTest::UnitTest
  def setup
    super
    @account = logged_account
  end

  def test_account_requests_use_account_token_on_public_url
    @fake.on(:GetTagRequest, { GetTagResponse: {} })

    @account.tags.all

    request = @fake.last_request(:GetTagRequest)
    assert_equal @account.token.to_s, request.header.dig(:context, :authToken)
    assert_equal Zm::SoapRequest::SoapAccountConstants::ACCOUNT_SERVICE_URI, request.path
  end

  def test_tags_all_builds_tags
    tags_json = [{ id: '64', name: 'urgent', color: 1 }, { id: '65', name: 'todo' }]
    @fake.on(:GetTagRequest, { GetTagResponse: { tag: tags_json } })

    tags = @account.tags.all

    assert_equal %w[64 65], tags.map(&:id)
    assert_equal %w[urgent todo], tags.map(&:name)
    assert(tags.all?(Zm::Client::Tag))
  end

  def test_tags_all_without_tags_returns_empty_array
    @fake.on(:GetTagRequest, { GetTagResponse: {} })

    assert_equal [], @account.tags.all
  end

  def test_tag_create_sends_name_and_color
    @fake.on(:CreateTagRequest) do |request|
      { CreateTagResponse: { tag: [request.body[:tag].merge(id: '70')] } }
    end

    tag = @account.tags.new do |t|
      t.name = 'new tag'
      t.color = 4
    end
    tag.create!

    assert_equal({ name: 'new tag', color: 4 }, @fake.last_request(:CreateTagRequest).body[:tag])
    assert_equal '70', tag.id
  end

  def test_tag_create_existing_raises
    @fake.fault(:CreateTagRequest, code: 'mail.ALREADY_EXISTS')

    tag = @account.tags.new { |t| t.name = 'existing' }

    error = assert_raises(Zm::Error::SoapError) { tag.create! }
    assert_equal 'mail.ALREADY_EXISTS', error.code
  end

  def test_folder_retention_policies_are_merged_in_one_request
    @fake.on(:FolderActionRequest, { FolderActionResponse: {} })
    folder = @account.folders.new { |f| f.id = 257 }
    folder.retention_policies.create(:keep, '30d', 'user')
    folder.retention_policies.create(:purge, '365d', 'user')

    assert folder.retention_policies.save!

    action = @fake.last_request(:FolderActionRequest).body[:action]
    assert_equal 'retentionpolicy', action[:op]
    assert_equal({ keep: { policy: { lifetime: '30d', type: 'user' } },
                   purge: { policy: { lifetime: '365d', type: 'user' } } },
                 action[:retentionPolicy])
  end
end
