module Interfaces
  module UserErrorPayload
    include Interfaces::BaseInterface

    field :user_errors, [Types::UserError], null: false
  end
end
