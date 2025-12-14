# frozen_string_literal: true

module Zm
  module Client
    module Base
      # Abstract Class Collection
      class ObjectsCollection
        include Zm::Inspector

        METHODS_MISSING_LIST = %i[select each map length].to_set.freeze
        attr_reader :parent

        def new
          child = @child_class.new(@parent)
          yield(child) if block_given?
          child
        end

        def find(id)
          find_by(id: id)
        end

        def first
          @limit = 1
          build_response.first
        end

        def all
          build_response
        end
        alias all! all

        def per_page(limit)
          return self if @limit == limit

          @limit = limit
          self
        end
        alias limit per_page

        def page(offset)
          return self if @offset == offset

          @offset = offset
          self
        end
        alias offset page

        def order(sort_by, sort_ascending = SoapUtils::ON)
          return self if @sort_by == sort_by && @sort_ascending == sort_ascending

          @sort_by = sort_by
          @sort_ascending = sort_ascending
          self
        end

        def method_missing(method, *, &)
          if METHODS_MISSING_LIST.include?(method)
            build_response.send(method, *, &)
          else
            super
          end
        end

        def respond_to_missing?(method, *)
          METHODS_MISSING_LIST.include?(method) || super
        end

        def logger
          @parent.logger
        end

        private

        def build_response
          @builder_class.new(@parent, make_query).make
        end

        def soap_admin_connector
          @parent.soap_admin_connector
        end
        alias sac soap_admin_connector

        def attrs_comma
          return @attrs unless @attrs.is_a?(Array)

          # @attrs.uniq!
          # @attrs.compact!
          return nil if @attrs.empty?

          @attrs.join(COMMA)
        end

        def reset_query_params
          @max_result = SoapUtils::MAX_RESULT
          @limit = nil
          @offset = nil
          @sort_by = nil
          @sort_ascending = SoapUtils::ON
          @count_only = SoapUtils::OFF
          @all_servers = SoapUtils::OFF
          @refresh = SoapUtils::OFF
          @apply_cos = SoapUtils::ON
        end
      end
    end
  end
end
