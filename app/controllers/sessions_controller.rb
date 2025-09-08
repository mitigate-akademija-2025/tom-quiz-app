class SessionsController < ApplicationController
  allow_unauthenticated_access only: %i[ new create omniauth ]
  rate_limit to: 10, within: 3.minutes, only: :create, with: -> { redirect_to new_session_url, alert: "Try again later." }

  def new
  end

  def create
    if user = User.authenticate_by(params.permit(:email_address, :password))
      # Check if this is an OAuth-only user trying to use password
      if user.oauth_user? && user.password_digest.blank?
        redirect_to new_session_path,
          alert: "Please sign in using #{user.provider.titleize} as you registered with that service."
        return
      end

      if user.confirmed?
        start_new_session_for user
        redirect_to after_authentication_url
      else
        redirect_to new_session_path(email_address: user.email_address),
          alert: "Please confirm your email before signing in."
      end
    else
      redirect_to new_session_path, alert: "Try another email address or password."
    end
  end

  # OAuth callback handler
  def omniauth
    begin
      user = User.from_omniauth(request.env["omniauth.auth"])

      if user.persisted?
        start_new_session_for user

        # Determine appropriate success message
        if user.created_at > 1.minute.ago
          flash_message = "Welcome! Your account has been created and you're now signed in."
        else
          flash_message = "Successfully signed in with #{user.provider.titleize}!"
        end

        redirect_to after_authentication_url, notice: flash_message
      else
        Rails.logger.error "OAuth user creation failed: #{user.errors.full_messages.join(', ')}"
        redirect_to new_session_path, alert: "Authentication failed. Please try again."
      end
    rescue => e
      Rails.logger.error "OAuth authentication error: #{e.message}"
      redirect_to new_session_path, alert: "Authentication failed. Please try again."
    end
  end

  # OAuth failure handler
  def failure
    error_reason = params[:message]&.humanize || "Authentication failed"
    redirect_to new_session_path,
      alert: "#{error_reason}. Please try again or sign in with your email and password."
  end

  def destroy
    terminate_session
    redirect_to new_session_path
  end
end
