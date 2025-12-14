# frozen_string_literal: true

require 'msgpack'

module Zm
  module Support
    module Cache
      class Entry
        class << self
          def factory
            @factory ||= MessagePack::Factory.new.tap do |msgpack_factory|
              msgpack_factory.register_type(
                0x01,
                self,
                packer: ->(entry) { entry.pack.to_msgpack },
                unpacker: lambda { |data|
                  value, expires_at, version = MessagePack.unpack(data)
                  new(Marshal.load(value), version: version, expires_at: expires_at)
                }
              )
            end
          end
        end

        attr_reader :value, :version, :expires_at

        def initialize(value, version: 1, expires_in: nil, expires_at: nil)
          @value      = value
          @version    = version.to_i
          @expires_at = expires_at&.to_f || (expires_in && (expires_in.to_f + Time.now.to_f))
        end

        def to_s
          inspect
        end

        def inspect # :nodoc:
          "#<#{self.class.name} value=#{@value}, version=#{@version}, expires_at=#{@expires_at}>"
        end

        def mismatched?(version)
          version && @version != version
        end

        def expired?
          return false unless @expires_at

          @expires_at <= Time.now.to_f
        end

        def pack
          members = [Marshal.dump(@value), @expires_at, @version]
          members.pop while !members.empty? && members.last.nil?
          members
        end

        def dump
          self.class.factory.dump self
        end
      end
    end
  end
end
