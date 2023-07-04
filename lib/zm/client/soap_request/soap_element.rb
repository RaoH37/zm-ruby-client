# frozen_string_literal: true

module Zm
  module Client
    class SoapElement
      class << self
        def create(name)
          new(name, nil)
        end

        def account(name)
          new(name, SoapAccountConstants::NAMESPACE_STR)
        end

        def mail(name)
          new(name, SoapMailConstants::NAMESPACE_STR)
        end

        def admin(name)
          new(name, SoapAdminConstants::NAMESPACE_STR)
        end
      end

      attr_reader :name

      def initialize(name, namespace)
        @name = name
        @namespace = namespace
        @attributes = {}
        @nodes = []
        @content = nil
      end

      def add_attribute(key, value)
        @attributes[key.to_sym] = value
        self
      end

      def add_attributes(hash)
        return self if hash.nil?

        hash.transform_keys!(&:to_sym)
        @attributes.merge!(hash)
        self
      end

      def add_content(content)
        @content = content
        self
      end

      def add_node(node)
        @nodes << node
        self
      end

      def to_json(*_args)
        to_hash.to_json
      end

      def to_struct
        struct = properties

        @nodes.each do |node|
          if struct[node.name].nil?
            struct.merge!(node.to_hash)
          else
            struct[node.name] = [struct[node.name]] unless struct[node.name].is_a?(Array)
            struct[node.name] << node.to_struct
          end
        end

        struct
      end

      def to_hash
        { @name => to_struct }
      end

      def properties
        return @content.map { |content| { _content: content } } if @content.is_a?(Array)

        hash = @namespace.nil? ? {} : { _jsns: @namespace }
        hash.merge!(@attributes) unless @attributes.empty?
        hash.merge!({ _content: @content }) unless @content.nil?
        hash
      end
    end
  end
end
