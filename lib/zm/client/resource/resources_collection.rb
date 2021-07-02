# frozen_string_literal: true

module Zm
  module Client
    # Collection Resources
    class ResourcesCollection < Base::ObjectsCollection
      def initialize(parent)
        @child_class = Resource
        @parent = parent
        reset_query_params
      end

      def ldap
        @apply_cos = 0
        self
      end

      def find_by(hash)
        rep = sac.get_resource(hash.values.first, hash.keys.first, attrs_comma)
        entry = rep[:Body][:GetCalendarResourceResponse][:calresource].first

        build_from_entry(entry)
      end

      private

      def build_response
        ResourcesBuilder.new(@parent, make_query).make
      end

      def reset_query_params
        super
        @search_type = SearchType::RESOURCE
        @attrs = SearchType::Attributes::RESOURCE.dup
        @all_servers = 1
        @refresh = 0
        @apply_cos = 1
      end
    end
  end
end
