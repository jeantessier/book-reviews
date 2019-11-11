class Book < ApplicationRecord
  has_many :authors, class_name: BookAuthor, dependent: :destroy, inverse_of: :book
  has_many :years, class_name: BookYear, dependent: :destroy, inverse_of: :book
  has_many :titles, class_name: BookTitle, dependent: :destroy, inverse_of: :book
end
