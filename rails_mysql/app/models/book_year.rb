class BookYear < ApplicationRecord
  belongs_to :book, inverse_of: :authors

  validates_presence_of :year
  validates_numericality_of :order, greater_than_or_equal_to: 0
end