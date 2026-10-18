# Changelog

## Released [3.1.]

### [3.1.0] 2026-07

- [Added] Add massive update and delete in admin collection classes
- [Added] Add optional TLS certificate verification in ClusterConfig (ssl_verify, ssl_ca_file, ssl_ca_path), disabled by default
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
- [Changed] Reduce allocations when building objects from SOAP responses (about 90% fewer for accounts)
- [Changed] Autoload cache stores and msgpack: the default null_store no longer loads msgpack and FileStore (about 1.2 MB less)
- [Added]   Add Zm::Support::Cache.storage(key), registered_storage may now hold constant names (Symbol) instead of classes
- [Fixed]   Autoload ClusterConfigError and ClusterConfigDomain (NameError when referenced before ClusterConfig was loaded)
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