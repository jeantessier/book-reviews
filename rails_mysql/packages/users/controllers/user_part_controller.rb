class UserPartController < ApplicationController
  before_action :authenticate_user!, only: [ :create, :update, :destroy ]
  before_action :set_user
  attr_reader :user

  private

  def set_user
    @user = User.find(params[:user_id])
  end
end
