class UsersController < ApplicationController
  allow_unauthenticated_access only: [ :new, :create, :confirm ]
  before_action :set_user, except: [ :new, :create ]
  before_action :set_key_type, only: [ :edit_api_key, :update_api_key, :destroy_api_key ]

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    @user.generate_confirmation_token

    if @user.save
      UserMailer.confirmation_email(@user).deliver_later
      redirect_to root_path, notice: "Check your email to confirm your account."
    else
      render :new, status: :unprocessable_content
    end
  end

  def destroy
    @user.destroy
    reset_session
    redirect_to root_path, notice: "Your account has been deleted."
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
    @api_key = @user.api_key_for(@key_type.name) || @user.api_keys.build(key_type: @key_type)
  end

  def update_api_key
    result = @user.update_api_key(
      key_type: @key_type,
      key_value: params.dig(:api_key, :new_key)
    )

    if result[:success]
      redirect_to profile_user_path(@user), notice: result[:message]
    else
      @api_key = result[:record]
      flash.now[:alert] = result[:message]
      render :edit_api_key, status: :unprocessable_content
    end
  end

  def destroy_api_key
    api_key = @user.api_key_for(params[:api_type])
    if api_key
      api_key.destroy
      redirect_to profile_user_path(@user), notice: "#{@key_type.name.titleize} API key deleted."
    else
      redirect_to profile_user_path(@user), alert: "No API key found to delete."
    end
  end

  def confirm
    puts("Confirmation token: #{params[:token]}!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
    user = User.find_by(confirmation_token: params[:token])
    if user && user.confirmation_sent_at > 2.days.ago
      user.update(confirmed_at: Time.current, confirmation_token: nil)
      redirect_to new_session_path, notice: "Your account is confirmed!"
    else
      redirect_to root_path, alert: "Invalid or expired confirmation link."
    end
  end


  private

  def set_user
    @user = current_user
  end

  def set_key_type
    @key_type = KeyType.find_by(name: params[:api_type])

    unless @key_type
      redirect_to profile_user_path(@user), alert: "Invalid API key type"
      false
    end
  end

  def user_params
    params.expect(user: [ :email_address, :password, :password_confirmation ])
  end

  def email_params
    params.expect(user: [ :email_address ])
  end

  def password_params
    params.expect(user: [ :password, :password_confirmation ])
  end
end
