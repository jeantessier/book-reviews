module Types
  class TitleType < Types::BaseObject
    field :title, String, null: false
    field :link, String, null: true
  end
end
