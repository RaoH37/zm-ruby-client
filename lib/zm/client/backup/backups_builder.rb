# frozen_string_literal: true

module Zm
  module Client
    # class factory [Backup]
    class BackupsBuilder < Base::ObjectsBuilder
      def make
        return [] if json_items.nil?

        json_items.map do |entry|
          BackupJsnsInitializer.create(@parent, entry)
        end
      end

      private

      def json_items
        @json_items ||= @json[:Body][json_key][:backup]
      end
    end
  end
end
