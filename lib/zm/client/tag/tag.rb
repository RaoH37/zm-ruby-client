module Zm
  module Client
    class Tag < Base::Object
      attr_accessor :id, :name, :color, :rgb, :u, :n, :d, :rev, :md, :ms

      def init_from_json(json)
        @id      = json[:id]
        @name    = json[:name]
        @color   = json[:color]
        @rgb     = json[:rgb]
        @u       = json[:u]
        @n       = json[:n]
        @d       = json[:d]
        @rev     = json[:rev]
        @md      = json[:md]
        @ms      = json[:ms]
      end
    end
  end
end
