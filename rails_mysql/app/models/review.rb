class Review < ApplicationRecord
  belongs_to :reviewer, class_name: User.to_s
  belongs_to :book

  validates_presence_of :body
end
