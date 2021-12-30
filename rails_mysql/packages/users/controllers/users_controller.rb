class UsersController < ApplicationController
  before_action :set_user

  # GET /users/1
  def show
    render json: @user
  end

  private

  def set_user
    @user = User.find(params[:id])
  end
end
