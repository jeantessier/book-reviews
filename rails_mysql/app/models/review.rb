class Review < ApplicationRecord
  belongs_to :reviewer, class_name: User
  belongs_to :book

  validates_presence_of :body
end
