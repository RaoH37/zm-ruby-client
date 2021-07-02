# frozen_string_literal: true

module Zm
  module Client
    # Collection coses
    class CosesCollection < Base::ObjectsCollection
      def initialize(parent)
        @child_class = Cos
        @parent = parent
        reset_query_params
      end

      def find_by(hash, *attrs)
        rep = sac.get_cos(hash.values.first, hash.keys.first, attrs.join(COMMA))
        entry = rep[:Body][:GetCosResponse][:cos].first

        build_from_entry(entry)
      end

      private

      def build_response
        CosesBuilder.new(@parent, make_query).make
      end

      def reset_query_params
        super
        @search_type = SearchType::COS
        @attrs = SearchType::Attributes::COS.dup
      end
    end
  end
end
