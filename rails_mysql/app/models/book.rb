class Book < ApplicationRecord
  has_many :authors, class_name: BookAuthor.to_s, dependent: :destroy, inverse_of: :book
  has_many :years, class_name: BookYear.to_s, dependent: :destroy, inverse_of: :book
  has_many :titles, class_name: BookTitle.to_s, dependent: :destroy, inverse_of: :book
  has_many :reviews, dependent: :destroy, inverse_of: :book
  has_many :reviewers, through: :reviews
end
