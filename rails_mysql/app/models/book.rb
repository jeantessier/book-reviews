class Book < ApplicationRecord
  has_many :authors, class_name: BookAuthor, dependent: :destroy, inverse_of: :book
end
