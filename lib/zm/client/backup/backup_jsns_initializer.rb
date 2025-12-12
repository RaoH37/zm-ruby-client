# frozen_string_literal: true

module Zm
  module Client
    # class for initialize backup
    class BackupJsnsInitializer
      class << self
        def create(parent, json)
          Backup.new(parent).tap do |item|
            update(item, json)
          end
        end
        
        def update(item, json)
          item.label = json.delete(:label)
          item.type = json.delete(:type)
          item.aborted = json.delete(:aborted)
          item.start = json.delete(:start)
          item.end = json.delete(:end)
          item.minRedoSeq = json.delete(:minRedoSeq)
          item.maxRedoSeq = json.delete(:maxRedoSeq)
          item.live = json.delete(:live)
          item.accounts = json.delete(:accounts)
        end
      end
    end
  end
end
