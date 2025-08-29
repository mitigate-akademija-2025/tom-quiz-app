class ApplicationController < ActionController::Base
  include Authentication
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Make these available to views
  helper_method :current_user, :current_user_id, :owner_of?, :current_user?

  # User authentication helpers
  def current_user
    Current.session&.user
  end

  def current_user_id
    Current.session&.user_id
  end

  # Authorization helpers
  def owner_of?(resource)
    return false unless authenticated?
    return false unless resource&.respond_to?(:user_id)

    current_user_id == resource.user_id
  end

  def current_user?(user)
    return false unless user&.respond_to?(:id)

    current_user_id == user.id
  end
end
