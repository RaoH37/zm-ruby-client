# Changelog

## Released [3.1.0]

### [3.1.0] 2026-07

#### Upgrading from 3.0

- **Ruby 3.3 or newer is required.**
- **Only `require 'zm-ruby-client'` is supported.** Files were moved and are now autoloaded: requiring internal
  files (`zm/client/...`) no longer works.
- **Error classes moved from `Zm::Client` to `Zm::Error`.** The 3.0 names still work in 3.1 but print a deprecation
  warning on first use and will be removed in 4.0. Update your `rescue` clauses:

  | 3.0 (deprecated) | 3.1 |
  |---|---|
  | `Zm::Client::ZmError` | `Zm::Error::ZmError` |
  | `Zm::Client::SoapError` | `Zm::Error::SoapError` |
  | `Zm::Client::AuthError` | `Zm::Error::AuthError` |
  | `Zm::Client::RestError` | `Zm::Error::RestError` |

- **Network failures raise `Zm::Error::ConnectionError`** (a `Zm::Error::ZmError`) instead of Faraday errors
  (`Faraday::ConnectionFailed`, `Faraday::TimeoutError`, `Faraday::SSLError`). The Faraday error is kept as `cause`.
- **Low-level classes moved out of `Zm::Client`.** The 3.0 names are deprecated the same way:

  | 3.0 (deprecated) | 3.1 |
  |---|---|
  | `Zm::Client::SoapAdminConnector`, `SoapAccountConnector`, `SoapBaseConnector`, `RestConnector` | `Zm::Connector::*` |
  | `Zm::Client::SoapElement`, `SoapConstants`, `SoapAdminConstants`, `SoapAccountConstants`, `SoapMailConstants` | `Zm::SoapRequest::*` |
  | `Zm::Client::SoapUtils` | `Zm::Utils::SearchUtils` |
  | `Zm::Client::Regex`, `ContentType`, `ContentPart` | `Zm::Utils::*` |

- **Renamed without alias:** the top-level `GroupContact` and `DocumentFolder` modules are now
  `Zm::Client::ModGroupContact` and `Zm::Client::ModDocumentFolder`.
- **Removed constants:** `Zm::Client::ShareType`, `FolderType`, `SearchType`, `BackupTypes`, `CountTypes`, `COMMA` and
  `DOUBLEPOINT`. Use the plain values instead, for example `cluster.count_object(:account)` or
  `cluster.count_object('account')`.
- **`ZimbraAttribute` keeps only `name`, `type`, `immutable?` and `objects_scope`** (plus the `is_*_scoped?`
  predicates): `optionalIn`, `requiredIn`, `flags`, `cardinality`, `callback`, `value`, `max`, `min` and `since` were
  removed, as well as `ZimbraAttributesCollection#all_versioned`. The attributes catalog is read from the CSV file only
  (`zimbra-attrs.json` was removed from the gem).
- **Cache:** only read requests (`Get*`, `Search*`, `Count*`) are cached and entries are stored with msgpack. Entries
  written by 3.0 are ignored: you can delete the old `file_store` directory.
- **Stricter arguments:** `Utils.format_email` raises `ArgumentError` on a nil, non-String or blank email, and
  distribution list members `add!`/`remove!` raise `ArgumentError` on nil instead of returning false.
- **`clone` no longer shares collections with the original:** a cloned distribution list starts with empty `members`
  and `owners` (aliases are rebuilt from `zimbraMailAlias`).
- **`Contact#l` is a String** (`'7'` for a new contact), like the other mailbox items.
- TLS certificates are still not verified by default: set `ssl_verify` to enable it.

#### Changes

- [Added]   Deprecated aliases for the 3.0 names moved out of Zm::Client (error classes, connectors, SoapElement, SOAP constants, SoapUtils, Regex, ContentType, ContentPart): they print a warning on first use and will be removed in 4.0
- [Fixed]   Cluster#count_object accepts a String again ('account', as in 3.0) as well as a Symbol
- [Added]   Add live CRUD tests (accounts, account folders, appointments, contacts, identities, messages, signatures and tags, resources, distribution lists, domains, coses) against a real server in test/live, rake test:live task configured by ZIMBRA_ADMIN_URL, ZIMBRA_ADMIN_LOGIN and ZIMBRA_ADMIN_PASSWORD
- [Fixed]   ContactJsnsBuilder no longer sends internal instance variables (updated, token, tags, folder, shared account ids) as contact attributes
- [Fixed]   GroupContactJsnsBuilder: to_create and to_patch raised NameError, the folder is read from l, members are sent without op on creation
- [Fixed]   MessageFlagsCollection: read!, unread!, flag! and unflag! raised NoMethodError (soap_connector called on the message instead of its account)
- [Changed] MessageFlagsCollection: read!, unread!, flag! and unflag! update the message flags (f) after the request
- [Fixed]   Contact: the default folder (l) is set through l= and is a String like the other mailbox items
- [Fixed]   Base::Object#clone: the copy no longer shares the memoized jsns builder and collections of the original (a clone of a created identity or cos sent the original name), and no longer raises when the original has no id
- [Added]   Add RBS signatures for the public API in sig/ (cluster, config, errors, admin objects and collections, mailbox entry points), rake rbs:validate and rbs:test tasks
- [Added]   Add massive update and delete in admin collection classes
- [Added]   Add optional TLS certificate verification in ClusterConfig (ssl_verify, ssl_ca_file, ssl_ca_path), disabled by default
- [Changed] Cache only read SOAP requests (Get*, Search*, Count*): write and auth requests are no longer replayed from cache
- [Changed] Store cache entries with msgpack only (no Marshal), cache files created with 0600 and directories with 0700: existing cache entries are ignored
- [Fixed]   Mask passwords, preauth and auth tokens in debug and verbose HTTP logs
- [Changed] Raise Zm::Error::ConnectionError (original Faraday error as cause) on connection failure, timeout and SSL error instead of Faraday errors
- [Fixed]   REST download and read error messages were always empty (streamed body), error pages are no longer written to the destination file
- [Fixed]   Alias, distribution list member and owner add!/remove! raised FrozenError on frozen emails and mutated the given strings
- [Changed] Utils.format_email raises ArgumentError on nil, non-String or blank email instead of NoMethodError
- [Fixed]   Delegated account connector shared the cluster SOAP context: every following admin request carried the account header
- [Fixed]   Server#mailboxes and AccountsCollection#quotas left the target server set on the cluster admin connector
- [Fixed]   MessagesCollection#find_each(secure: true) looped forever when the search request failed
- [Changed] Replace require by autoload to reduce memory usage
- [Changed] Share the Zimbra attributes catalog between clusters using the same attributes file (CSV parsed and accessors defined once)
- [Changed] ZimbraAttribute keeps only name, type, immutable? and objects_scope (catalog memory reduced by about 65%): optionalIn, requiredIn, flags, cardinality, callback, value, max, min and since readers removed
- [Removed] Remove unused zimbra-attrs.json file from the gem
- [Removed] Remove ZimbraAttributesCollection#all_versioned (never set, always nil)
- [Changed] Reduce allocations when building objects from SOAP responses (about 90% fewer for accounts)
- [Changed] Autoload cache stores and msgpack: the default null_store no longer loads msgpack and FileStore (about 1.2 MB less)
- [Added]   Add Zm::Support::Cache.storage(key), registered_storage may now hold constant names (Symbol) instead of classes
- [Fixed]   Autoload ClusterConfigError and ClusterConfigDomain (NameError when referenced before ClusterConfig was loaded)
- [Fixed]   Autoload Attachment and DlMembership (NameError when referenced before their collection was loaded)
- [Fixed]   Require time explicitly: Time.parse (created_at, last_logon, appointments) only worked because csv loaded it
- [Fixed]   DistributionListMembersCollection add!/remove! raise ArgumentError on nil instead of returning false
- [Changed] Change code structure files
- [Changed] Add secure option in messages find_each method
- [Changed] Require Ruby 3.3 minimum
- [Changed] Add csv and logger dependencies, remove bundler dependency, pin dependency major versions
- [Fixed]   Fix default zimbra attributes file path in ClusterConfig
- [Fixed]   Remove duplicated Recipient class in MessageRecipients
- [Fixed]   Rename TagBuilder to TagsBuilder to match autoload (account tags raised NameError)
- [Fixed]   Remove duplicated attribute accessors in SearchFolder
- [Fixed]   Accept keyword attributes in admin update!, update_all! and mass_update! (local_transport! raised ArgumentError)
- [Fixed]   Rescue Zm::Error::SoapError in mass_update! and mass_delete! (onerror option raised NameError)
- [Changed] Fix indentation in several collection classes

## Released [3.0.0]

### [3.0.0] 2025-12(27)

- [Changed] Move token metadata decoder in token class
- [Changed] Move logger in ClusterConfig class
- [Added]   Add color in logger
- [Added]   Add NoOpRequest for Mailbox object as alive? method
- [Changed] Remove @all memorization
- [Added]   Add BatchRequest on Cluster and Account class
- [Changed] Authorize array and undetermined parameters for add! and remove! methods
- [Changed] Memory optimization in object initializers
- [Changed] Replace FolderDefault as Data object
- [Changed] Modify config admin and public url format
- [Added]   Can access mailbox objects without mailbox login