class UsersController < ApplicationController
  allow_unauthenticated_access only: [ :new, :create ]
  before_action :set_user, except: [ :new, :create ]

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)

    if @user.save
      start_new_session_for(@user)
      redirect_to root_path, notice: "Welcome! Your account has been created."
    else
      render :new, status: :unprocessable_content
    end
  end

  def profile
  end

  def edit_email
  end

  def update_email
    if @user.update(email_params)
      redirect_to profile_user_path(@user), notice: "Email updated"
    else
      render :edit_email, status: :unprocessable_content
    end
  end

  def edit_password
  end

  def update_password
    if @user.update(password_params)
      redirect_to profile_user_path(@user), notice: "Password updated"
    else
      render :edit_password, status: :unprocessable_content
    end
  end

  def edit_api_key
  end

  def update_api_key
    if @user.update(api_key_params)
      redirect_to profile_user_path(@user), notice: "API key updated"
    else
      render :edit_api_key, status: :unprocessable_content
    end
  end

  private

  def set_user
    @user = current_user
  end

  def email_params
    params.expect(user: [ :email_address ])
  end

  def password_params
    params.expect(user: [ :password, :password_confirmation ])
  end

  def api_key_params
    params.expect(user: [ :api_key ])
  end
end
