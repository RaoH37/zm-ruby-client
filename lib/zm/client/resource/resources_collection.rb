module Zm
  module Client
    # Collection Resources
    class ResourcesCollection < Base::ObjectsCollection
      def initialize(parent)
        @parent = parent
        reset_query_params
      end

      def find_by(hash, *attrs)
        rep = sac.get_resource(hash.values.first, hash.keys.first, attrs.join(COMMA))
        entry = rep[:Body][:GetCalendarResourceResponse][:calresource].first
        resource = Resource.new(@parent)
        resource.init_from_json(entry)
        resource
      end

      private

      def build_response
        ResourcesBuilder.new(@parent, make_query).make
      end

      def reset_query_params
        super
        @search_type = SearchType::RESOURCE
        @attrs = SearchType::Attributes::RESOURCE
      end
    end
  end
end
