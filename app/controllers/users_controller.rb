class UsersController < ApplicationController
  allow_unauthenticated_access only: [ :new, :create ]
  before_action :set_user, only: [ :edit, :update ]

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)

    if @user.save
      start_new_session_for(@user)
      redirect_to root_path, notice: "Welcome! Your account has been created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @user.update(user_params)
      redirect_to edit_user_path(@user), notice: "Profile updated successfully."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_user
    @user = User.find(params[:id])
    redirect_to root_path, alert: "Not authorized" unless current_user?(@user)
  end

  def user_params
    if params[:user][:password].blank?
      params.expect(user: [ :email_address ])
    else
      params.expect(user: [ :email_address, :password, :password_confirmation ])
    end
  end
end
