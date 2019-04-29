module Zm
  module Client
    class ShareBuilder < Base::ObjectsBuilder
      def initialize(parent, json)
        @parent = parent
        @json = json
      end

      def make
        root = @json[:Body][:GetShareInfoResponse][:share]
        return [] if root.nil?

        root = [root] unless root.is_a?(Array)
        root.map do |s|
          Share.new(@parent, s)
        end
      end
    end
  end
end
