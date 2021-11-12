class BookRepository
  def self.all
    books.values
  end

  def self.save(book)
    raise "Duplicate ID \"#{book[:id]}\"" if books.include?(book[:id])
    books[book[:id]] = book
  end

  def self.find_by_id(id)
    books[id]
  end

  def self.find_by_name(name)
    all.find { |b| b[:name] == name }
  end

  def self.remove(id)
    !(books.delete(id).nil?)
  end

  private

  def self.books
    @books ||= {}
  end
end
