# frozen_string_literal: true

require_relative '../test_helper'

class FoldersBuilderTest < ZmTest::UnitTest
  def setup
    super
    @account = logged_account
  end

  def test_abs_folder_path_is_computed_when_missing
    root = { id: '1', name: 'USER_ROOT', folder: [
      { id: '2', name: 'Inbox', view: 'message', folder: [
        { id: '257', name: 'projects', view: 'message', folder: [
          { id: '258', name: '2026', view: 'message' }
        ] }
      ] },
      { id: '16', name: 'Briefcase', view: 'document' }
    ] }
    @fake.on(:GetFolderRequest, { GetFolderResponse: { folder: [root] } })

    folders = @account.folders.all

    assert_equal({ '1' => '/', '2' => '/Inbox', '257' => '/Inbox/projects', '258' => '/Inbox/projects/2026',
                   '16' => '/Briefcase' },
                 folders.to_h { |folder| [folder.id, folder.absFolderPath] })
  end

  def test_abs_folder_path_from_the_response_is_kept
    root = { id: '1', name: 'USER_ROOT', absFolderPath: '/', folder: [
      { id: '257', name: 'projects', absFolderPath: '/renamed', view: 'message', folder: [
        { id: '258', name: '2026', view: 'message' }
      ] }
    ] }
    @fake.on(:GetFolderRequest, { GetFolderResponse: { folder: [root] } })

    folders = @account.folders.all

    assert_equal %w[/ /renamed /renamed/2026], folders.map(&:absFolderPath)
  end

  def test_type_defaults_to_folder_when_missing
    @fake.on(:GetFolderRequest, { GetFolderResponse: { folder: [{ id: '1', name: 'USER_ROOT' }] } })

    assert_equal [:folder], @account.folders.all.map(&:type)
  end
end
