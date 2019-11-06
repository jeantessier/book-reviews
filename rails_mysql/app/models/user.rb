class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  alias_method :authenticate, :valid_password?

  def to_token_payload
    {
        sub: self.id,
        iat: DateTime.now.strftime("%s").to_i,
        iss: "http://github.com/jeantessier/book-reviews",
        name: self.name,
    }
  end
end
