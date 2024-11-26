module Mutations
  class UserMutation < Mutations::BaseMutation
    argument :name, String, required: true

    object_class Mutations::UserMutationPayload

    field :user, Types::UserType, null: true

    def resolve(name:)
      user = User.find_by name:
      if user.nil?
        add_user_error argument: :name, message: 'No user by that name'
      end

      with_user_errors user:
    end
  end
end
