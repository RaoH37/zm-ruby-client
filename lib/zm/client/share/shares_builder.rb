module Zm
  module Client
    class ShareBuilder < Base::ObjectsBuilder
      def initialize account, json
        @account = account
        @json    = json
      end

      def make
        root = @json[:Body][:GetShareInfoResponse][:share]
        return [] if root.nil?
        root = [root] if !root.is_a?(Array)
        @json[:Body][:GetShareInfoResponse][:share].map{|s| Share.new(@account, s) }
      end
    end
  end
end