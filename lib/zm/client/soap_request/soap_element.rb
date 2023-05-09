module Zm
  module Client
    class SoapElement
      class << self
        def create(name)
          new(name, nil)
        end

        def admin(name)
          new(name, SoapAdminConstants::NAMESPACE_STR)
        end
      end

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

      def to_json
        to_hash.to_json
      end

      def to_hash
        struct = properties
        @nodes.each do |node|
          struct.merge!(node.to_hash)
        end
        { @name => struct }
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
