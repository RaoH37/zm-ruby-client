module MissingMethodStaticCollection
  attr_reader :all

  def method_missing(method, *args, &block)
    if @all.respond_to?(method)
      @all.send(method, *args, &block)
    else
      super
    end
  end
end