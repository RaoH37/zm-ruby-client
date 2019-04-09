module Zm
  module Client
    # class factory [resources]
    class ResourcesBuilder < Base::ObjectsBuilder
      def make
        records = []
        return records if json_items.nil?

        json_items.each do |entry|
          resource = Resource.new(@parent)
          resource.init_from_json(entry)
          records << resource
        end
        records
      end

      private

      def json_items
        @json_items ||= @json[:Body][json_key][:calresource]
      end
    end
  end
end
