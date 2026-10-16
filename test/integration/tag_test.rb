# frozen_string_literal: true

require_relative 'integration_helper'

class TagIntegrationTest < ZmTest::IntegrationTest
  def setup
    @admin = Zm::Client::Cluster.new(Zm::Client::ClusterConfig.new(CONFIG_PATH))
    @admin.login

    @account = @admin.accounts.find_by name: fixture(:accounts).dig('accounts', 'maxime', 'email')
    @account.login
    @created_tags = []
  end

  def teardown
    @created_tags.each do |tag|
      tag.delete!
    rescue Zm::Error::SoapError
      nil
    end
  end

  def test_all
    assert_kind_of Array, @account.tags.all
  end

  def test_create
    tag = create_tag

    refute_nil tag.id
    assert_includes @account.tags.all!.map(&:id), tag.id
  end

  def test_create_with_existing_name_raises
    tag = create_tag

    duplicate = @account.tags.new { |t| t.name = tag.name }
    assert_raises(Zm::Error::SoapError) { duplicate.create! }
  end

  def test_modify
    tag = create_tag(color: 1)
    tag.color = 5

    assert tag.modify!
    assert_equal 5, find_tag(tag.id).color
  end

  def test_rename
    tag = create_tag
    new_name = unique_name('tag-renamed')

    tag.rename!(new_name)

    assert_equal new_name, find_tag(tag.id).name
  end

  def test_delete
    tag = create_tag
    tag.delete!
    @created_tags.delete(tag)

    assert_nil find_tag(tag.id)
  end

  private

  def create_tag(color: 4)
    tag = @account.tags.new do |t|
      t.name = unique_name('tag')
      t.color = color
    end
    tag.create!
    @created_tags << tag
    tag
  end

  def find_tag(id)
    @account.tags.all!.find { |t| t.id == id }
  end
end
