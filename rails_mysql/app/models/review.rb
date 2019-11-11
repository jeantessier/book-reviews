class Review < ApplicationRecord
  belongs_to :reviewer
  belongs_to :book
end
