# frozen_string_literal: true

module Zm
  module Client
    module FolderAttrs
      def self.included(base)
        base.class_eval do
          extend Philosophal::Properties

          cprop :type, String, default: :folder
          cprop :id, Integer
          cprop :uuid, String
          cprop :name, String
          cprop :absFolderPath, Pathname
          cprop :l, Integer, default: FolderDefault::ROOT[:id]
          cprop :luuid, String
          cprop :f, String
          cprop :color, Integer
          cprop :rgb, String
          cprop :u, Integer
          cprop :view, String, default: FolderView::MESSAGE
          cprop :rev, Integer
          cprop :ms, Integer
          cprop :md, Integer
          cprop :n, Integer
          cprop :i4n, Integer
          cprop :s, Integer
          cprop :i4ms, Integer
          cprop :i4next, Integer
          cprop :url, String
          cprop :webOfflineSyncDays, Integer
          cprop :activesyncdisabled, _Boolean
          cprop :zid, String
          cprop :rid, String
          cprop :ruuid, String
          cprop :recursive, Integer
          cprop :rest, String
          cprop :deletable, _Boolean
          cprop :itemCount, Integer
          cprop :broken, Integer
          cprop :fb, Integer
        end
      end
    end
  end
end
