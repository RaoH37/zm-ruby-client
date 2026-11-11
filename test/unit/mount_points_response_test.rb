# frozen_string_literal: true

require_relative '../test_helper'

class MountPointsResponseTest < ZmTest::UnitTest
  ROOT = { id: '1', name: 'USER_ROOT', link: [
    { id: '300', name: 'Shared inbox', view: 'message', zid: 'owner-1', rid: '2' },
    { id: '301', name: 'Team calendar', view: 'appointment', zid: 'owner-2', rid: '10' }
  ], folder: [
    { id: '2', name: 'Inbox', view: 'message', link: [
      { id: '302', name: 'Shared projects', view: 'message', zid: 'owner-1', rid: '257' }
    ] },
    { id: '16', name: 'Briefcase', view: 'document', folder: [
      { id: '260', name: 'Sub', view: 'document', link: [
        { id: '303', name: 'Shared docs', view: 'document', zid: 'owner-3', rid: '16' }
      ] }
    ] },
    { id: '7', name: 'Contacts', view: 'contact', link: [
      { id: '304', name: 'Shared contacts', view: 'contact', zid: 'owner-1', rid: '7' }
    ] },
    { id: '15', name: 'Tasks', view: 'task', link: [
      { id: '305', name: 'Shared tasks', view: 'task', zid: 'owner-2', rid: '15' }
    ] }
  ] }.freeze

  def setup
    super
    @account = logged_account
    @fake.on(:GetFolderRequest, { GetFolderResponse: { folder: [ROOT] } })
  end

  def test_all_returns_a_mount_points_response
    mountpoints = @account.mountpoints.all

    assert_instance_of Zm::Client::MountPointsResponse, mountpoints
    assert_kind_of Array, mountpoints
    assert_equal %w[300 301 302 303 304 305], mountpoints.map(&:id)
    assert(mountpoints.all?(Zm::Client::MountPoint))
  end

  def test_filters_by_view
    mountpoints = @account.mountpoints.all

    assert_equal %w[300 302], mountpoints.messages.map(&:id)
    assert_equal %w[301], mountpoints.appointments.map(&:id)
    assert_equal %w[304], mountpoints.contacts.map(&:id)
    assert_equal %w[305], mountpoints.tasks.map(&:id)
    assert_equal %w[303], mountpoints.documents.map(&:id)
    assert_equal %w[301], mountpoints.by_view('appointment').map(&:id)
  end

  def test_without_link_returns_an_empty_response
    @fake.on(:GetFolderRequest, { GetFolderResponse: { folder: [{ id: '1', name: 'USER_ROOT' }] } })

    mountpoints = @account.mountpoints.all

    assert_instance_of Zm::Client::MountPointsResponse, mountpoints
    assert_empty mountpoints
  end

  def test_share_mountpoints_are_selected_from_the_response
    share = Zm::Client::Share.new(@account)
    share.ownerId = 'owner-1'
    share.folderId = '2'

    assert_equal %w[300], share.mountpoints.all.map(&:id)
  end

  def test_folders_response_keeps_the_view_filters
    assert_includes Zm::Client::FoldersResponse.ancestors, Zm::Client::FolderViewFilters
  end
end
