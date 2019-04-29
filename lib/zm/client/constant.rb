module Zm
  module Client
    COMMA = ','.freeze
    DOUBLEPOINT = ' :: '.freeze

    module FolderDefault
      ROOT = { id: 1, path: '/', type: 'unknown' }.freeze
      BRIEFCASE = { id: 16, path: '/Briefcase', type: 'document' }.freeze
      CALENDAR = { id: 10, path: '/Calendar', type: 'appointment' }.freeze
      CHATS = { id: 14, path: '/Chats', type: 'message' }.freeze
      CONTACTS = { id: 7, path: '/Contacts', type: 'contact' }.freeze
      DRAFTS = { id: 6, path: '/Drafts', type: 'message' }.freeze
      EMAILED = { id: 13, path: '/Emailed Contacts', type: 'contact' }.freeze
      INBOX = { id: 2, path: '/Inbox', type: 'message' }.freeze
      JUNK = { id: 4, path: '/Junk', type: 'message' }.freeze
      SENT = { id: 5, path: '/Sent', type: 'message' }.freeze
      TASKS = { id: 15, path: '/Tasks', type: 'task' }.freeze
      TRASH = { id: 3, path: '/Trash', type: 'unknown' }.freeze

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
    end

    module ShareType
      VIEWER  = :r
      MANAGER = :rwidx
      ADMIN   = :rwidxa
    end

    module FolderView
      UNKNOWN     = :unknown
      MESSAGE     = :message
      APPOINTMENT = :appointment
      TASK        = :task
      DOCUMENT    = :document
      CONTACT     = :contact
      ALL         = [MESSAGE, APPOINTMENT, TASK, DOCUMENT, CONTACT].freeze
    end

    module FolderType
      FOLDER = :folder
      LINK   = :link
      ALL    = [FOLDER, LINK].freeze
    end

    module SoapUtils
      MAX_RESULT   = 1_000_000
      ON           = 1
      OFF          = 0
      OFFSET       = 0
      LIMIT_RESULT = 10_000
    end

    module SearchType
      ACCOUNT  = :accounts
      DL       = :distributionlists
      ALIAS    = :aliases
      RESOURCE = :resources
      DOMAIN   = :domains
      COS      = :coses

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
      MAILBOX = 'mailbox'.freeze
    end
  end
end
