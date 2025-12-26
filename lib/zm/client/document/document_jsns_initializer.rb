# frozen_string_literal: true

module Zm
  module Client
    # class for account document
    class DocumentJsnsInitializer
      class << self
        def create(parent, json)
          Document.new(parent).tap do |item|
            update(item, json)
          end
        end

        def update(item, json)
          item.id = json.delete(:id)
          item.uuid = json.delete(:uuid)
          item.name = json.delete(:name)
          item.s = json.delete(:s)
          item.d = json.delete(:d)
          item.l = json.delete(:l)
          item.luuid = json.delete(:luuid)
          item.ms = json.delete(:ms)
          item.mdver = json.delete(:mdver)
          item.md = json.delete(:md)
          item.rev = json.delete(:rev)
          item.f = json.delete(:f)
          item.tn = json.delete(:tn)
          item.t = json.delete(:t)
          item.meta = json.delete(:meta)
          item.ct = json.delete(:ct)
          item.descEnabled = json.delete(:descEnabled)
          item.ver = json.delete(:ver)
          item.leb = json.delete(:leb)
          item.cr = json.delete(:cr)
          item.cd = json.delete(:cd)
          item.acl = json.delete(:acl)
          item.loid = json.delete(:loid)
          item.sf = json.delete(:sf)

          item
        end
      end
    end
  end
end
