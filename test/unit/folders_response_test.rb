# frozen_string_literal: true

require_relative '../test_helper'

class FoldersResponseTest < ZmTest::UnitTest
  ROOT = { id: '1', name: 'USER_ROOT', folder: [
    { id: '2', name: 'Inbox', view: 'message', folder: [
      { id: '257', name: 'projects', view: 'message' }
    ] },
    { id: '7', name: 'Contacts', view: 'contact' },
    { id: '10', name: 'Calendar', view: 'appointment' },
    { id: '258', name: 'Team', view: 'appointment' },
    { id: '15', name: 'Tasks', view: 'task' },
    { id: '16', name: 'Briefcase', view: 'document' }
  ] }.freeze

  def setup
    super
    @account = logged_account
    @fake.on(:GetFolderRequest, { GetFolderResponse: { folder: [ROOT] } })
  end

  def test_all_returns_a_folders_response
    folders = @account.folders.all

    assert_instance_of Zm::Client::FoldersResponse, folders
    assert_kind_of Array, folders
    assert_equal %w[1 2 257 7 10 258 15 16], folders.map(&:id)
  end

  def test_filters_by_view
    folders = @account.folders.all

    assert_equal %w[2 257], folders.messages.map(&:id)
    assert_equal %w[10 258], folders.appointments.map(&:id)
    assert_equal %w[7], folders.contacts.map(&:id)
    assert_equal %w[15], folders.tasks.map(&:id)
    assert_equal %w[16], folders.documents.map(&:id)
    assert_equal %w[10 258], folders.by_view('appointment').map(&:id)
  end

  def test_immutables
    assert_equal %w[1 2 7 10 15 16], @account.folders.all.immutables.map(&:id)
  end

  def test_where_view_keeps_a_folders_response
    folders = @account.folders.appointment.all

    assert_instance_of Zm::Client::FoldersResponse, folders
    assert_equal %w[10 258], folders.map(&:id)
  end
end
