class Book

  attr_accessor :name

  def initialize(**options)
    if options.has_key? :name
      @name = options[:name]
    end
  end

end
