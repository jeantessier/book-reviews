class RegistrationsController < Devise::RegistrationsController
  respond_to :json

  protected

  def sign_up_params
    # super
    params.require(:registration).permit(:email, :password)
  end
end
