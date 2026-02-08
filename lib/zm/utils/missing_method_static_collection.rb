# frozen_string_literal: true

module Zm
  module Utils
    module MissingMethodStaticCollection
      attr_reader :all

      def method_missing(method, *, &)
        if @all.respond_to?(method)
          @all.send(method, *, &)
        else
          super
        end
      end
    end
  end
end
