class BookYear < ApplicationRecord
  # Optional so the tests can create transient instances.
  # Otherwise, we get "Validation failed: Book must exist" errors.
  belongs_to :book, inverse_of: :authors, optional: true

  validates_presence_of :year
  validates_numericality_of :order, greater_than_or_equal_to: 0

  def <=>(other)
    order <=> other.order
  end
end
