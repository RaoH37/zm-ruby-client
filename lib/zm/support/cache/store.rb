# frozen_string_literal: true

module Zm
  module Support
    module Cache
      class Store
        attr_reader :options
        attr_writer :logger

        def initialize(options = {})
          @options = options
          @coder = Cache::Entry.factory
          @digest = OpenSSL::Digest.new('sha256')
          @logger = nil
        end

        def fetch(name, options = nil, &)
          if block_given?
            options = merged_options(options)
            key = normalize_key(name, options)

            entry = nil

            unless options[:force]
              cached_entry = read_entry(key, **options)
              entry = handle_expired_entry(cached_entry, key, options)

              entry = nil if entry&.mismatched?(normalize_version(options))
            end

            if entry
              @logger&.info 'Load from cache'
              entry.value
            else
              save_block_result_to_cache(key, options, &)
            end
          elsif options && options[:force]
            raise ArgumentError, 'Missing block: Calling `Cache#fetch` with `force: true` requires a block.'
          else
            read(name, options)
          end
        end

        def read(name, options = nil)
          options = merged_options(options)
          key     = normalize_key(name, options)
          version = normalize_version(options)

          entry = read_entry(key, **options)

          return unless entry

          if entry.expired? || entry.mismatched?(version)
            delete_entry(key, **options)
            nil
          else
            @logger&.info 'Load from cache'
            entry.value
          end
        end

        def write(name, value, options = nil)
          options = merged_options(options)
          key = normalize_key(name, options)
          version = normalize_version(options)

          entry = Entry.new(value, **options, version: version)
          write_entry(key, entry, **options)
        end

        def delete(name, options = nil)
          options = merged_options(options)
          key = normalize_key(name, options)

          delete_entry(key, **options)
        end

        def exist?(name, options = nil)
          options = merged_options(options)
          key = normalize_key(name, options)
          version = normalize_version(options)

          entry = read_entry(key, **options)
          (entry && !entry.expired? && !entry.mismatched?(version)) || false
        end

        def clear(_options = nil)
          raise NotImplementedError
        end

        def cleanup(_options = nil)
          raise NotImplementedError
        end

        private

        def normalize_options(call_options)
          options.merge(call_options)
        end

        def normalize_version(call_options = nil)
          if call_options&.key?(:version)
            call_options[:version]
          else
            options[:version]
          end
        end

        def normalize_key(key, call_options = nil)
          namespace = if call_options&.key?(:namespace)
                        call_options[:namespace]
                      else
                        options[:namespace]
                      end

          if namespace
            @digest.hexdigest("#{namespace}:#{key}")
          else
            @digest.hexdigest(key)
          end
        end

        def read_entry(_key, **_options)
          raise NotImplementedError
        end

        def write_entry(_key, _entry, **_options)
          raise NotImplementedError
        end

        def delete_entry(_key, **_options)
          raise NotImplementedError
        end

        def merged_options(call_options)
          if call_options
            call_options = normalize_options(call_options)
            if call_options.key?(:expires_in) && call_options.key?(:expires_at)
              raise ArgumentError, 'Either :expires_in or :expires_at can be supplied, but not both'
            end

            expires_at = call_options.delete(:expires_at)
            call_options[:expires_in] = (expires_at - Time.now) if expires_at

            if call_options[:expires_in].is_a?(Time)
              expires_in = call_options[:expires_in]
              raise ArgumentError,
                    "expires_in parameter should not be a Time. Did you mean to use expires_at? Got: #{expires_in}"
            end

            if call_options[:expires_in]&.negative?
              expires_in = call_options.delete(:expires_in)
              raise ArgumentError, "Cache expiration time is invalid, cannot be negative: #{expires_in}"
            end

            if options.empty?
              call_options
            else
              options.merge(call_options)
            end
          else
            options
          end
        end

        def handle_expired_entry(entry, key, options)
          if entry&.expired?
            delete_entry(key, **options)
            entry = nil
          end

          entry
        end

        def save_block_result_to_cache(key, options)
          version = normalize_version(options)

          value = yield

          entry = Entry.new(value, **options, version: version)
          write_entry(key, entry, **options)
          value
        end

        def serialize_entry(entry, **)
          @coder.dump(entry)
        end

        def deserialize_entry(payload, **)
          @coder.load(payload)
        rescue DeserializationError
          nil
        end
      end
    end
  end
end
