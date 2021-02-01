# frozen_string_literal: true

module Zm
  module Client
    # Collection Backups
    class BackupsCollection < Base::ObjectsCollection
      def initialize(parent)
        @parent = parent
      end

      private

      def make_query
        sac.backup_query(@parent.id)
      end

      def build_response
        BackupsBuilder.new(@parent, make_query).make
      end
    end
  end
end
