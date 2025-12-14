# frozen_string_literal: true

module Zm
  module Client
    module Base
      # Collection AdminObjectsCollection
      class AdminObjectsCollection < ObjectsCollection
        def initialize(parent)
          @parent = parent
          @persistent = false
          reset_query_params
        end

        def find_by(hash)
          find_by!(hash)
        end

        def find_by_or_nil(hash, error_handler = SoapError)
          find_by(hash)
        rescue error_handler => _e
          nil
        end

        def ldap
          @apply_cos = SoapUtils::OFF
          self
        end

        def where(ldap_query)
          ldap_filter.add(ldap_query)

          self
        end

        def attrs(*attributes)
          attributes.flatten!
          attributes.map! { |attr| attr.to_s.strip }
          attributes.sort!
          attributes.uniq!
          attributes.delete_if { |attr| attr.nil? || attr.empty? }

          return self if @attrs == attributes

          @attrs = attributes
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
          ldap_filter.clear
          reset_query_params
          self
        end

        def find_each(offset: 0, limit: 1_000, &block)
          previous_persistent = @persistent.dup
          @persistent = true

          _attrs = @attrs
          total = count
          @attrs = _attrs

          @offset = offset
          @limit = limit

          while @offset < total
            build_response.each { |item| block.call(item) }
            @offset += @limit
          end

          ldap_filter.clear
          reset_query_params

          @persistent = previous_persistent
        end

        def make_query
          response = sac.invoke(build_query)
          clear unless @persistent
          response
        end

        def build_query
          SoapElement.admin(SoapAdminConstants::SEARCH_DIRECTORY_REQUEST)
                     .add_attributes(jsns)
        end

        private

        def ldap_filter
          return @ldap_filter if defined? @ldap_filter

          @ldap_filter = LdapFilter.new
        end

        def jsns
          h = {
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
          }
          h.compact!
          h
        end
      end
    end
  end
end
