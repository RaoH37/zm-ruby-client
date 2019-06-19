# frozen_string_literal: true

module Zm
  module Client
    COMMA = ','
    DOUBLEPOINT = ' :: '

    module FolderDefault
      ROOT = { id: 1, name: '', path: '/', type: 'unknown' }.freeze
      BRIEFCASE = { id: 16, name: 'Briefcase', path: '/Briefcase', type: 'document' }.freeze
      CALENDAR = { id: 10, name: 'Calendar', path: '/Calendar', type: 'appointment' }.freeze
      CHATS = { id: 14, name: 'Chats', path: '/Chats', type: 'message' }.freeze
      CONTACTS = { id: 7, name: 'Contacts', path: '/Contacts', type: 'contact' }.freeze
      DRAFTS = { id: 6, name: 'Drafts', path: '/Drafts', type: 'message' }.freeze
      EMAILED = { id: 13, name: 'Emailed Contacts', path: '/Emailed Contacts', type: 'contact' }.freeze
      INBOX = { id: 2, name: 'Inbox', path: '/Inbox', type: 'message' }.freeze
      JUNK = { id: 4, name: 'Junk', path: '/Junk', type: 'message' }.freeze
      SENT = { id: 5, name: 'Sent', path: '/Sent', type: 'message' }.freeze
      TASKS = { id: 15, name: 'Tasks', path: '/Tasks', type: 'task' }.freeze
      TRASH = { id: 3, name: 'Trash', path: '/Trash', type: 'unknown' }.freeze

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

      IDS = ALL.map { |folder| folder[:id] }.freeze
    end

    module ShareType
      VIEWER = :r
      MANAGER = :rwidx
      ADMIN = :rwidxa
    end

    module FolderView
      UNKNOWN = :unknown
      MESSAGE = :message
      APPOINTMENT = :appointment
      TASK = :task
      DOCUMENT = :document
      CONTACT = :contact
      ALL = [MESSAGE, APPOINTMENT, TASK, DOCUMENT, CONTACT].freeze
    end

    module FolderType
      FOLDER = :folder
      LINK = :link
      ALL = [FOLDER, LINK].freeze
    end

    module SoapUtils
      MAX_RESULT = 1_000_000
      ON = 1
      OFF = 0
      OFFSET = 0
      LIMIT_RESULT = 10_000
    end

    module SearchType
      ACCOUNT = :accounts
      DL = :distributionlists
      ALIAS = :aliases
      RESOURCE = :resources
      DOMAIN = :domains
      COS = :coses

      module Attributes
        ACCOUNT = %i[
          displayName
          zimbraId
          cn
          sn
          zimbraMailHost
          uid
          zimbraCOSId
          zimbraAccountStatus
          zimbraLastLogonTimestamp
          description
          zimbraIsSystemAccount
          zimbraIsDelegatedAdminAccount
          zimbraAuthTokenValidityValue
          zimbraMailStatus
          zimbraIsAdminAccount
          zimbraIsExternalVirtualAccount
        ].freeze

        DL = %i[
          displayName
          zimbraId
          zimbraMailHost
          uid
          description
          zimbraIsAdminGroup
          zimbraMailStatus
          zimbraIsDelegatedAdminAccount
          zimbraIsAdminAccount
          zimbraIsSystemResource
          zimbraIsSystemAccount
          zimbraIsExternalVirtualAccount
        ].freeze

        ALIAS = %i[
          zimbraAliasTargetId
          zimbraId
          targetName
          uid
          type
          description
          zimbraIsDelegatedAdminAccount
          zimbraIsAdminAccount
          zimbraIsSystemResource
          zimbraIsSystemAccount
          zimbraIsExternalVirtualAccount
        ].freeze

        RESOURCE = %i[
          displayName
          zimbraId
          zimbraMailHost
          uid
          zimbraAccountStatus
          description
          zimbraCalResType
          zimbraIsDelegatedAdminAccount
          zimbraIsAdminAccount
          zimbraIsSystemResource
          zimbraIsSystemAccount
          zimbraIsExternalVirtualAccount
        ].freeze

        DOMAIN = %i[
          description
          zimbraDomainName
          zimbraDomainStatus
          zimbraId
          zimbraDomainType
          zimbraDomainDefaultCOSId
        ].freeze

        COS = %i[
          cn
          description
          zimbraMailHostPool
          zimbraMailQuota
        ].freeze
      end
    end
    module ServerServices
      MAILBOX = 'mailbox'
    end
  end
end
