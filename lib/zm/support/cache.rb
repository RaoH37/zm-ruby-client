# frozen_string_literal: true

module Zm
  module Support
    module Cache
      class << self

      end

      class Store
        def initialize(options = nil)

        end

        def fetch(name, options = nil, &block)
          if block_given?
            options = merged_options(options)
            key = normalize_key(name, options)

            entry = nil
            unless options[:force]
              instrument(:read, key, options) do |payload|
                cached_entry = read_entry(key, **options, event: payload)
                entry = handle_expired_entry(cached_entry, key, options)
                if entry
                  if entry.mismatched?(normalize_version(name, options))
                    entry = nil
                  else
                    begin
                      entry.value
                    rescue DeserializationError
                      entry = nil
                    end
                  end
                end
                payload[:super_operation] = :fetch if payload
                payload[:hit] = !!entry if payload
              end
            end

            if entry
              get_entry_value(entry, name, options)
            else
              save_block_result_to_cache(name, key, options, &block)
            end
          elsif options && options[:force]
            raise ArgumentError, "Missing block: Calling `Cache#fetch` with `force: true` requires a block."
          else
            read(name, options)
          end
        end

        def read(name, options = nil)
          options = merged_options(options)
          key     = normalize_key(name, options)
          version = normalize_version(name, options)

          instrument(:read, key, options) do |payload|
            entry = read_entry(key, **options, event: payload)

            if entry
              if entry.expired?
                delete_entry(key, **options)
                payload[:hit] = false if payload
                nil
              elsif entry.mismatched?(version)
                payload[:hit] = false if payload
                nil
              else
                payload[:hit] = true if payload
                begin
                  entry.value
                rescue DeserializationError
                  payload[:hit] = false
                  nil
                end
              end
            else
              payload[:hit] = false if payload
              nil
            end
          end
        end

        def write(name, value, options = nil)
          options = merged_options(options)
          key = normalize_key(name, options)

          instrument(:write, key, options) do
            entry = Entry.new(value, **options.merge(version: normalize_version(name, options)))
            write_entry(key, entry, **options)
          end
        end

        # Deletes an entry in the cache. Returns +true+ if an entry is deleted
        # and +false+ otherwise.
        #
        # Options are passed to the underlying cache implementation.
        def delete(name, options = nil)
          options = merged_options(options)
          key = normalize_key(name, options)

          instrument(:delete, key, options) do
            delete_entry(key, **options)
          end
        end

        def exist?(name, options = nil)
          options = merged_options(options)
          key = normalize_key(name, options)

          instrument(:exist?, key) do |payload|
            entry = read_entry(key, **options, event: payload)
            (entry && !entry.expired? && !entry.mismatched?(normalize_version(name, options))) || false
          end
        end
      end
    end
  end
end
