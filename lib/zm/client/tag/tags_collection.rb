module Zm
  module Client
    class TagsCollection < Base::ObjectsCollection
      def initialize(parent)
        @parent = parent
      end

      def new
        tag = Tag.new(@parent)
        yield(tag) if block_given?
        tag
      end

      def all
        rep = @parent.sacc.get_tag(@parent.token)
        tb = TagBuilder.new @parent, rep
        tb.make
      end
    end
  end
end