# frozen_string_literal: true

module Zm
  module Client
    # class factory [Backup]
    class BackupsBuilder < Base::ObjectsBuilder
      def initialize(parent, json)
        super
        @json_item_key = :backup
      end

      def make
        return [] if json_items.nil?

        json_items.map do |entry|
          BackupJsnsInitializer.create(@parent, entry)
        end
      end
    end
  end
end
