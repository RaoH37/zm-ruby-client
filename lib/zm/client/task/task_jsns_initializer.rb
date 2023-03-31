# frozen_string_literal: true

module Zm
  module Client
    # class for account document
    class TaskJsnsInitializer
      class << self
        def create(parent, json)
          item = Task.new(parent)
          update(item, json)
        end

        def update(item, json)
          item.uid = json[:uid]
          item.priority = json[:priority].to_i
          item.ptst = json[:ptst]
          item.percentComplete = json[:percentComplete].to_f
          item.name = json[:name]
          item.loc = json[:loc]
          item.alarm = json[:alarm]
          item.isOrg = json[:isOrg]
          item.id = json[:id].to_i
          item.invId = json[:invId]
          item.compNum = json[:compNum]
          item.l = json[:l].to_i
          item.status = json[:status]
          item.class = json[:class]
          item.allDay = json[:allDay]
          item.f = json[:f]
          item.tn = json[:tn]
          item.t = json[:t]
          item.rev = json[:rev]
          item.s = json[:s]
          item.d = json[:d]
          item.md = json[:md]
          item.ms = json[:ms]
          item.cm = json[:cm]
          item.sf = json[:sf]

          item
        end
      end
    end
  end
end
