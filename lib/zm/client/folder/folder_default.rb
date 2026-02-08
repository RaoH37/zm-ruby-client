# frozen_string_literal: true

module Zm
  module Client
    module FolderDefault
      FolderData = Data.define(:id, :name, :path, :type)

      ROOT = FolderData.new(1, '', '/', 'unknown')
      INBOX = FolderData.new(2, 'Inbox', '/Inbox', 'message')
      TRASH = FolderData.new(3, 'Trash', '/Trash', 'unknown')
      JUNK = FolderData.new(4, 'Junk', '/Junk', 'message')
      SENT = FolderData.new(5, 'Sent', '/Sent', 'message')
      DRAFTS = FolderData.new(6, 'Drafts', '/Drafts', 'message')
      CONTACTS = FolderData.new(7, 'Contacts', '/Contacts', 'contact')
      CALENDAR = FolderData.new(10, 'Calendar', '/Calendar', 'appointment')
      EMAILED = FolderData.new(13, 'Emailed Contacts', '/Emailed Contacts', 'contact')
      CHATS = FolderData.new(14, 'Chats', '/Chats', 'message')
      TASKS = FolderData.new(15, 'Tasks', '/Tasks', 'task')
      BRIEFCASE = FolderData.new(16, 'Briefcase', '/Briefcase', 'document')

      ALL = [
        ROOT,
        BRIEFCASE,
        CALENDAR,
        CHATS,
        CONTACTS,
        DRAFTS,
        EMAILED,
        INBOX,
        JUNK,
        SENT,
        TASKS,
        TRASH
      ].freeze

      IDS = ALL.map(&:id).freeze
    end
  end
end
