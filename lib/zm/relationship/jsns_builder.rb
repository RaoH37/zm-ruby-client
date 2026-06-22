# frozen_string_literal: true

module Zm
  module Relationship
    class JsnsBuilder
      def initialize(klass:)
        @klass = klass
      end

      attr_reader :name, :klass

      def generate_relation_method(buffer = +'')
        buffer <<
          'def jsns_builder' << "\n" \
          'return @jsns_builder if defined? @jsns_builder' << "\n" \
          '@jsns_builder = ' << @klass.name << '.new(self)' << "\n" \
          "end\n"
      end
    end
  end
end
