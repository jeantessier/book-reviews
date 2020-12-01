class Review < ApplicationRecord
  belongs_to :reviewer, inverse_of: :reviews, class_name: User.to_s
  belongs_to :book, inverse_of: :reviews

  validates_presence_of :body
end
