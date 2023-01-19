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

        def find_by(hash)
          item = find_in_cache(hash)
          return item unless item.nil?

          find_by!(hash)
        end

        def ldap
          return self if @apply_cos == SoapUtils::ON

          @all = nil
          @apply_cos = SoapUtils::OFF
          self
        end

        def where(ldap_query)
          @all = nil if ldap_filter.add(ldap_query)

          self
        end

        def attrs(*attrs)
          return self if @attrs == attrs

          @all = nil
          @attrs = attrs
          self
        end

        def count
          reset_query_params
          @count_only = SoapUtils::ON
          json = make_query
          @count_only = SoapUtils::OFF
          json[:Body][:SearchDirectoryResponse][:num]
        end

        def clear
          @all = nil
          ldap_filter.clear
          reset_query_params
          self
        end

        def find_each
          total = count
          @all = []
          @offset = 0
          @limit = 1_000
          while @offset < total
            @all += build_response
            @offset += @limit
          end
          @offset = 0
          @all
        end

        private

        def make_query
          sac.search_directory(
            ldap_filter.join, @max_result, @limit, @offset,
            @domain_name, @apply_cos, @apply_config, @sort_by, @search_type,
            @sort_ascending, @count_only, attrs_comma
          )
        end

        def ldap_filter
          @ldap_filter ||= LdapFilter.new
        end

        def find_in_cache(hash)
          return nil if @all.nil?

          @all.find { |item| item.send(hash.keys.first) == hash.values.first }
        end
      end
    end
  end
end
