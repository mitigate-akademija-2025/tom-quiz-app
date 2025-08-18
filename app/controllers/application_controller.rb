class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  before_action :configure_permitted_parameters, if: :devise_controller?
  allow_browser versions: :modern

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:openai_api_key, :gemini_api_key])
    devise_parameter_sanitizer.permit(:account_update, keys: [:openai_api_key, :gemini_api_key])
  end
end

