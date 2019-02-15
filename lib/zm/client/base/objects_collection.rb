require 'set'
module Zm
  module Client
    module Base
      # Abstract Class Collection
      class ObjectsCollection
        METHODS_MISSING_LIST = %i[select each map].to_set.freeze
        attr_reader :parent

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

        def where(ldap_query)
          @ldap_query = ldap_query
          self
        end

        def per_page(limit)
          @limit = limit
          self
        end

        def page(offset)
          @offset = offset
          self
        end

        def order(sort_by, sort_ascending = SoapUtils::ON)
          @sort_by = sort_by
          @sort_ascending = sort_ascending
          self
        end

        def count
          @count_only = SoapUtils::ON
          make_query[:Body][:SearchDirectoryResponse][:num]
        end

        def attrs(*attrs)
          @attrs = attrs
          self
        end

        # def inspect
        #   build_response
        # end

        def method_missing(method, *args, &block)
          if METHODS_MISSING_LIST.include?(method)
            build_response.send(method, *args, &block)
          else
            super
          end
        end

        def respond_to_missing?(method, *)
          METHODS_MISSING_LIST.include?(method) || super
        end

        private

        def soap_admin_connector
          @parent.soap_admin_connector
        end

        alias sac soap_admin_connector

        # return ZCS JSON Response
        def make_query
          # puts "ObjectsCollection make_query #{@parent.class} #{@parent.object_id} #{@parent.soap_admin_connector}"
          json = sac.search_directory(
            @ldap_query, @max_result, @limit, @offset,
            @domain_name, nil, nil, @sort_by, @search_type,
            @sort_ascending, @count_only, @attrs.join(COMMA)
          )
          reset_query_params
          json
        end

        def reset_query_params
          @max_result = SoapUtils::MAX_RESULT
          @limit = nil
          @offset = nil
          @sort_by = nil
          @sort_ascending = SoapUtils::ON
          @count_only = SoapUtils::OFF
        end
      end
    end
  end
end
