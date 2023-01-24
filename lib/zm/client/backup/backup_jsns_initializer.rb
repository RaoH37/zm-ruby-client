# frozen_string_literal: true

module Zm
  module Client
    # class for initialize backup
    class BackupJsnsInitializer
      class << self
        def create(parent, json)
          item = Backup.new(parent)

          item.label = json[:label]
          item.type = json[:type]
          item.aborted = json[:aborted]
          item.start = json[:start].to_i
          item.end = json[:end].to_i
          item.minRedoSeq = json[:minRedoSeq]
          item.maxRedoSeq = json[:maxRedoSeq]
          item.live = json[:live]
          item.accounts = json[:accounts]

          item
        end
      end
    end
  end
end
