# frozen_string_literal: true

require 'fileutils'

module Zm
  module Support
    module Cache
      class FileStore < Store
        Cache.register_storage(:file_store, self)

        class << self
          def test_required_options(options)
            options.key?(:cache_path)
          end
        end

        attr_reader :cache_path

        GITKEEP_FILES = %w[.gitkeep .keep].freeze

        def initialize(**options)
          @cache_path = options.delete(:cache_path).to_s
          super(options)
        end

        def clear(options = nil)
          root_dirs = (Dir.children(cache_path) - GITKEEP_FILES)
          FileUtils.rm_r(root_dirs.collect { |f| File.join(cache_path, f) })
        rescue Errno::ENOENT, Errno::ENOTEMPTY => error
          @logger&.error "FileStoreError (#{error}): #{error.message}"
        end

        def cleanup(options = nil)
          options = merged_options(options)
          search_dir(cache_path) do |fname|
            entry = read_entry(fname, **options)
            delete_entry(fname, **options) if entry&.expired?
          end
        end

        def inspect # :nodoc:
          "#<#{self.class.name} cache_path=#{@cache_path}, options=#{@options.inspect}>"
        end

        private

        def read_entry(key, **options)
          if (payload = read_serialized_entry(key, **options))
            entry = deserialize_entry(payload)
            entry if entry.is_a?(Cache::Entry)
          end
        end

        def read_serialized_entry(key, **)
          File.binread(key) if File.exist?(key)
        rescue => error
          $stderr.puts "FileStoreError (#{error}): #{error.message}"
          nil
        end

        def write_entry(key, entry, **options)
          write_serialized_entry(key, serialize_entry(entry), **options)
        end

        def write_serialized_entry(key, payload, **)
          ensure_cache_path(File.dirname(key))
          File.open(key, 'w') { |f| f.write(payload) }
          true
        end

        def delete_entry(key, **options)
          if File.exist?(key)
            begin
              File.delete(key)
              delete_empty_directories(File.dirname(key))
              true
            rescue
              # Just in case the error was caused by another process deleting the file first.
              raise if File.exist?(key)
              false
            end
          else
            false
          end
        end

        # Translate a key into a file path.
        def normalize_key(key, options)
          key = super

          fpaths = []

          while key.length > 8
            chars = key.chars
            fpaths << chars.shift(8).join
            key = chars.join
          end

          File.join(cache_path, *fpaths, key)
        end

        # Translate a file path into a key.
        # def file_path_key(path)
        #   fname = path[cache_path.to_s.size..-1].split(File::SEPARATOR, 4).last.delete(File::SEPARATOR)
        #   URI.decode_www_form_component(fname, Encoding::UTF_8)
        # end

        def delete_empty_directories(dir)
          return if File.realpath(dir) == File.realpath(cache_path)

          if Dir.children(dir).empty?
            Dir.delete(dir) rescue nil
            delete_empty_directories(File.dirname(dir))
          end
        end

        def ensure_cache_path(path)
          FileUtils.makedirs(path) unless File.exist?(path)
        end

        def search_dir(dir, &callback)
          return unless File.exist?(dir)

          Dir.each_child(dir) do |d|
            name = File.join(dir, d)
            if File.directory?(name)
              search_dir(name, &callback)
            else
              callback.call name
            end
          end
        end
      end
    end
  end
end
