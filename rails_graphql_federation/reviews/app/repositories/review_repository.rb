class ReviewRepository
  def self.all
    reviews.values
  end

  def self.save(review)
    raise "Duplicate ID \"#{review[:id]}\"" if reviews.include?(review[:id])
    reviews[review[:id]] = review
  end

  def self.find_by_id(id)
    reviews[id]
  end

  def self.find_all_by_book(book_id)
    all.find_all { |r| r[:book][:id] == book_id }
  end

  def self.find_all_by_reviewer(reviewer_id)
    all.find_all { |r| r[:reviewer][:id] == reviewer_id }
  end

  def self.remove(id)
    !(reviews.delete(id).nil?)
  end

  private

  def self.reviews
    @reviews ||= {}
  end
end
