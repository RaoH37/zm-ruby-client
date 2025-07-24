# frozen_string_literal: true

module Zm
  module Client
    # class for account document
    class DocumentJsnsInitializer
      class << self
        def create(parent, json)
          item = Document.new(parent)
          update(item, json)
        end

        def update(item, json)
          item.id = json[:id]
          item.uuid = json[:uuid]
          item.name = json[:name]
          item.s = json[:s]
          item.d = json[:d]
          item.l = json[:l]
          item.luuid = json[:luuid]
          item.ms = json[:ms]
          item.mdver = json[:mdver]
          item.md = json[:md]
          item.rev = json[:rev]
          item.f = json[:f]
          item.tn = json[:tn]
          item.t = json[:t]
          item.meta = json[:meta]
          item.ct = json[:ct]
          item.descEnabled = json[:descEnabled]
          item.ver = json[:ver]
          item.leb = json[:leb]
          item.cr = json[:cr]
          item.cd = json[:cd]
          item.acl = json[:acl]
          item.loid = json[:loid]
          item.sf = json[:sf]

          item
        end
      end
    end
  end
end
