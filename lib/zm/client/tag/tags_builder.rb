module Zm
  module Client
    class TagBuilder < Base::ObjectsBuilder
      def initialize(account, json)
        @account = account
        @json    = json
      end

      def make
        root = @json[:Body][:GetTagResponse][:tag]
        return [] if root.nil?

        root = [root] unless root.is_a?(Array)
        root.map do |s|
          tag = Tag.new(@account)
          tag.init_from_json(s)
          tag
        end
      end
    end
  end
end