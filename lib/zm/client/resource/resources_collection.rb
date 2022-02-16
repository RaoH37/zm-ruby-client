# frozen_string_literal: true

module Zm
  module Client
    # Collection Resources
    class ResourcesCollection < Base::AdminObjectsCollection
      def initialize(parent)
        @child_class = Resource
        @builder_class = ResourcesBuilder
        @search_type = SearchType::RESOURCE
        super(parent)
      end

      def find_by(hash)
        rep = sac.get_resource(hash.values.first, hash.keys.first, attrs_comma)
        entry = rep[:Body][:GetCalendarResourceResponse][:calresource].first

        reset_query_params
        build_from_entry(entry)
      end

      private

      def reset_query_params
        super
        @attrs = SearchType::Attributes::RESOURCE.dup
        @all_servers = 1
        @refresh = 0
        @apply_cos = 1
      end
    end
  end
end
