# frozen_string_literal: true

module Zm
  module Client
    # class for account document
    class TaskJsnsInitializer
      class << self
        def create(parent, json)
          Task.new(parent).tap do |item|
            update(item, json)
          end
        end

        def update(item, json)
          item.uid = json.delete(:uid)
          item.priority = json.delete(:priority)
          item.ptst = json.delete(:ptst)
          item.percentComplete = json.delete(:percentComplete)
          item.name = json.delete(:name)
          item.loc = json.delete(:loc)
          item.alarm = json.delete(:alarm)
          item.isOrg = json.delete(:isOrg)
          item.id = json.delete(:id).to_i
          item.invId = json.delete(:invId)
          item.compNum = json.delete(:compNum)
          item.l = json.delete(:l).to_i
          item.status = json.delete(:status)
          item.class = json.delete(:class)
          item.allDay = json.delete(:allDay)
          item.f = json.delete(:f)
          item.tn = json.delete(:tn)
          item.t = json.delete(:t)
          item.rev = json.delete(:rev)
          item.s = json.delete(:s)
          item.d = json.delete(:d)
          item.md = json.delete(:md)
          item.ms = json.delete(:ms)
          item.cm = json.delete(:cm)
          item.sf = json.delete(:sf)

          item
        end
      end
    end
  end
end
