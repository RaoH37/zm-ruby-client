# frozen_string_literal: true

module Zm
  module Client
    # class factory [Backup]
    class BackupsBuilder < Base::ObjectsBuilder
      def make
        records = []
        return records if json_items.nil?

        json_items.each do |entry|
          backup = Backup.new(@parent)
          backup.init_from_json(entry)
          records << backup
        end
        records
      end

      private

      def json_items
        @json_items ||= @json[:Body][json_key][:backup]
      end
    end
  end
end
