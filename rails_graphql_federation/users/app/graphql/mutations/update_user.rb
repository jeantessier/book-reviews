module Mutations
  class UpdateUser < Mutations::BaseMutation
    argument :id, ID, required: true
    argument :name, String, required: false
    argument :email, String, required: false
    argument :password, String, required: false
    argument :roles, [String], required: false

    field :user, Types::UserType, null: true

    def resolve(id:, name: nil, email: nil, password: nil, roles: nil)
      user = UserRepository.find_by_id(id)
      raise "No user with ID #{id}" if user.nil?

      user_by_email = UserRepository.find_by_email(email)
      raise "Email \"#{email}\" is already taken" unless user_by_email == user || user_by_email.nil?

      user[:name] = name unless name.nil?
      user[:email] = email unless email.nil?
      user[:password] = password unless password.nil?
      user[:roles] = roles unless roles.nil?

      { user: user }
    end
  end
end
