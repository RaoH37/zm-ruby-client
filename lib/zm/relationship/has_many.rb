# frozen_string_literal: true

module Zm
  module Relationship
    class HasMany
      def initialize(name:, klass:)
        @name = name
        @klass = klass
      end

      attr_reader :name, :klass

      def generate_relation_method(buffer = +'')
        buffer <<
          'def ' << @name.name << "\n" \
          'return @' << @name.name << ' if defined? @' << @name.name << "\n" \
          '@' << @name.name << ' = ' << @klass.name << '.new(self)' << "\n" \
          "end\n"
      end
    end
  end
end
