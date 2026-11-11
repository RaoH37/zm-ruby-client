# frozen_string_literal: true

module Zm
  module Client
    # backups returned by BackupsCollection#all
    class BackupsResponse < Array
      def fulls
        self.class.new(select(&:full?))
      end

      def incrementals
        self.class.new(select(&:incremental?))
      end
    end
  end
end
