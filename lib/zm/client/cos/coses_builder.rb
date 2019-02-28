module Zm
  module Client
    # class factory [coses]
    class CosesBuilder < Base::ObjectsBuilder
      def make
        records = []
        return records if json_items.nil?

        json_items.each do |entry|
          cos = Cos.new(@parent)
          cos.init_from_json(entry)
          records << cos
        end
        records
      end

      private

      def json_items
        @json_items ||= @json[:Body][json_key][:cos]
      end
    end
  end
end
