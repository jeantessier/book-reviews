module Types
  class UserError < Types::BaseObject
    field :argument, String, null: false
    field :message, String, null: false
  end
end
