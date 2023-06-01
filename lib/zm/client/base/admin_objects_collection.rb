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

        def find_by_or_nil(hash, error_handler = SoapError)
          find_by(hash)
        rescue error_handler => _e
          nil
        end

        def ldap
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
          json[:SearchDirectoryResponse][:num]
        end

        def clear
          @all = nil
          ldap_filter.clear
          reset_query_params
          self
        end

        def find_each(step = 1_000)
          total = count
          @all = []
          @offset = 0
          @limit = step
          while @offset < total
            @all += build_response
            @offset += @limit
          end
          @offset = 0
          @all
        end

        private

        def make_query
          soap_request = SoapElement.admin(SoapAdminConstants::SEARCH_DIRECTORY_REQUEST)
          soap_request.add_attributes(jsns)
          sac.invoke(soap_request)
        end

        def ldap_filter
          @ldap_filter ||= LdapFilter.new
        end

        def find_in_cache(hash)
          return nil if @all.nil?

          @all.find { |item| item.send(hash.keys.first) == hash.values.first }
        end

        def jsns
          {
            query: ldap_filter.join,
            maxResults: @max_result,
            limit: @limit,
            offset: @offset,
            domain: @domain_name,
            applyCos: @apply_cos,
            applyConfig: @apply_config,
            sortBy: @sort_by,
            types: @search_type,
            sortAscending: @sort_ascending,
            countOnly: @count_only,
            attrs: attrs_comma
          }.reject { |_, v| v.nil? }
        end
      end
    end
  end
end
