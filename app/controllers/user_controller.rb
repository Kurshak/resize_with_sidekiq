# frozen_string_literal: true

class UserController < ApplicationController
  before_action :set_user, only: %i[show edit update]
  def index
    @users = User.all
  end

  def show; end

  def edit; end

  def update
    if @user.update(user_params)
      @user.delay.resize_image if @user.avatar.attached?
      redirect_to @user
    else
      render 'edit'
    end
  end

  private

  def set_user
    @user = User.find_by_id(params[:id])
  end

  def user_params
    params.require(:user).permit(:name, :status, :email, :phone, :avatar)
  end
end
