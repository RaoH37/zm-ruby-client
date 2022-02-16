# frozen_string_literal: true

module Zm
  module Client
    module Base
      # Collection AdminObjectsCollection
      class AdminObjectsCollection < ObjectsCollection
        def initialize(parent)
          @parent = parent
          reset_query_params
        end

        def ldap
          @apply_cos = 0
          self
        end

        def where(ldap_query)
          @all = nil
          ldap_filter.add(ldap_query)

          self
        end

        def attrs(*attrs)
          return self if @attrs == attrs

          @all = nil
          @attrs = attrs
          self
        end

        def count
          @count_only = SoapUtils::ON
          make_query[:Body][:SearchDirectoryResponse][:num]
        end

        private

        def make_query
          json = sac.search_directory(
            ldap_filter.join, @max_result, @limit, @offset,
            @domain_name, @apply_cos, @apply_config, @sort_by, @search_type,
            @sort_ascending, @count_only, attrs_comma
          )
          reset_query_params
          json
        end

        def ldap_filter
          @ldap_filter ||= LdapFilter.new
        end

        # def build_response
        #   @builder_class.new(@parent, make_query).make
        # end

        def reset_query_params
          super
          ldap_filter.clear
        end
      end
    end
  end
end
