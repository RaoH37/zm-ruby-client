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

      def create!
        rep = @parent.sacc.create_tag(@parent.token, @name, @color, @rgb)
        init_from_json(rep[:Body][:CreateTagResponse][:tag].first)
      end

      def delete!
        @parent.sacc.tag_action(@parent.token, :delete, @id)
      end

      def rename!(new_name)
        @parent.sacc.tag_action(
          @parent.token,
          :rename,
          @id,
          { name: new_name }
        )
      end
    end
  end
end
