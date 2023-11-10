# frozen_string_literal: true

module Zm
  module Client
    COMMA = ','
    DOUBLEPOINT = ' :: '

    module Regex
      UUID_REGEX = /[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}/.freeze
      BASEDN_REGEX = /^uid=/.freeze
      SHARED_CONTACT = /[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}:[0-9]+/.freeze
    end

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
      UNKNOWN = 'unknown'
      MESSAGE = 'message'
      APPOINTMENT = 'appointment'
      TASK = 'task'
      DOCUMENT = 'document'
      CONTACT = 'contact'
      ALL = [MESSAGE, APPOINTMENT, TASK, DOCUMENT, CONTACT].freeze
    end

    module FolderType
      FOLDER = :folder
      LINK = :link
      SEARCH = :search
      ALL = [FOLDER, LINK, SEARCH].freeze
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
        ACCOUNT = %w[
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

        DL = %w[
          displayName
          zimbraId
          zimbraMailHost
          uid
          description
          zimbraMailStatus
          zimbraMailAlias
        ].freeze

        ALIAS = %w[
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

        RESOURCE = %w[
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

        DOMAIN = %w[
          description
          zimbraDomainName
          zimbraDomainStatus
          zimbraId
          zimbraDomainType
          zimbraDomainDefaultCOSId
        ].freeze

        COS = %w[
          cn
          description
          zimbraMailHostPool
          zimbraMailQuota
        ].freeze
      end
    end

    module ServerServices
      AMAVIS = 'amavis'
      ANTIVIRUS = 'antivirus'
      ANTISPAM = 'antispam'
      OPENDKIM = 'opendkim'
      DNSCACHE = 'dnscache'
      LOGGER = 'logger'
      LDAP = 'ldap'
      SERVICE = 'service'
      ZIMBRA = 'zimbra'
      ZIMBRA_ADMIN = 'zimbraAdmin'
      ZIMLET = 'zimlet'
      MAILBOX = 'mailbox'
      MEMCACHED = 'memcached'
      SPELL = 'spell'
      MTA = 'mta'
      PROXY = 'proxy'
      STATS = 'stats'
      SNMP = 'snmp'
    end

    module MtaQueueName
      INCOMING = 'incoming'
      DEFERRED = 'deferred'
      CORRUPT = 'corrupt'
      ACTIVE = 'active'
      HOLD = 'hold'
      ALL = [INCOMING, DEFERRED, CORRUPT, ACTIVE, HOLD].freeze
    end

    module MtaQueueAction
      HOLD = 'hold'
      RELEASE = 'release'
      DELETE = 'delete'
      REQUEUE = 'requeue'
    end

    module BackupTypes
      FULL = 'full'
      INCREMENTAL = 'incremental'
    end

    module CountTypes
      USER_ACCOUNT = 'userAccount'
      ACCOUNT = 'account'
      ALIAS = 'alias'
      DL = 'dl'
      DOMAIN = 'domain'
      COS = 'cos'
      SERVER = 'server'
      RESOURCE = 'calresource'
      INTERNAL_USER_ACCOUNT = 'internalUserAccount'
      ALL = [USER_ACCOUNT, ACCOUNT, ALIAS, DL, DOMAIN, COS, SERVER, RESOURCE, INTERNAL_USER_ACCOUNT].freeze
    end

    module ContentType
      TEXT = 'text/plain'
      HTML = 'text/html'
      ALL = [TEXT, HTML].freeze
    end

    module ContentPart
      ALTERNATIVE = 'multipart/alternative'
    end
  end
end
