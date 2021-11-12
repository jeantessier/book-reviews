module Types
  class IndexEntry < Types::BaseObject
    field :score, Float, null: false
    field :id, ID, null: false
    field :type, String, null: false
  end
end
