# frozen_string_literal: true

module Zm
  module Client
    # Collection coses
    class CosesCollection < Base::AdminObjectsCollection
      def initialize(parent)
        @child_class = Cos
        @builder_class = CosesBuilder
        @search_type = SearchType::COS
        @parent = parent
      end

      def find_by(hash)
        rep = sac.get_cos(hash.values.first, hash.keys.first, attrs_comma)
        entry = rep[:Body][:GetCosResponse][:cos].first

        reset_query_params
        build_from_entry(entry)
      end

      private

      def reset_query_params
        super
        @attrs = SearchType::Attributes::COS.dup
      end
    end
  end
end
