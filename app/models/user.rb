class User < ApplicationRecord
  has_secure_password validations: false  # Handle validations manually
  has_many :sessions, dependent: :destroy
  has_many :quizzes, dependent: :destroy
  has_many :api_keys, dependent: :destroy
  has_many :key_types, through: :api_keys

  before_create :generate_confirmation_token, unless: :oauth_user?
  normalizes :email_address, with: ->(e) { e.strip.downcase }
  validates :email_address, presence: true, uniqueness: { case_sensitive: false }, unless: :oauth_user?

  # Password validations only for regular users
  validates :password, length: { minimum: 8, maximum: 128 },
            if: :password_required?
  validates :password, confirmation: true, if: :password_required?
  validate :password_complexity, if: :password_required?

  # OAuth user creation
  def self.from_omniauth(auth)
    # Check if an email is provided by the OAuth provider
    email = auth.info.email.present? ? auth.info.email : "#{auth.uid}@#{auth.provider}.com"

    # First check if user exists with this OAuth provider
    oauth_user = find_by(provider: auth.provider, uid: auth.uid)
    return oauth_user if oauth_user

    # Check if user exists with this email (account linking)
    existing_user = find_by(email_address: email)

    if existing_user && existing_user.regular_user?
      # Link OAuth to existing regular account
      existing_user.update!(
        provider: auth.provider,
        uid: auth.uid,
        name: auth.info.name,
        confirmed_at: Time.current  # Auto-confirm via OAuth
      )
      existing_user
    else
      # Create new OAuth user
      create!(
        email_address: email,
        name: auth.info.name,
        provider: auth.provider,
        uid: auth.uid,
        confirmed_at: Time.current,  # Auto-confirm OAuth users
        confirmation_sent_at: Time.current
        # No password_digest needed for OAuth users
      )
    end
  end

  # User type identification
  def oauth_user?
    provider.present? && uid.present?
  end

  def regular_user?
    provider.blank? && uid.blank?
  end

  def linked_user?
    oauth_user? && password_digest.present?
  end

  def update_api_key(key_type:, key_value: nil)
    api_key = api_key_for(key_type.name) || api_keys.build(key_type: key_type)
    api_key.new_key = key_value if key_value.present?

    if api_key.save
      { success: true, message: "#{key_type.name.humanize} API key updated.", record: api_key }
    else
      { success: false, message: "API key could not be updated.", record: api_key }
    end
  end

  def remove_api_key(key_type:)
    api_key = api_key_for(key_type.name)

    if api_key&.destroy
      { success: true, message: "#{key_type.name.humanize} API key removed." }
    else
      { success: false, message: "API key could not be removed." }
    end
  end

  def api_key_for(key_type_name)
    api_keys.includes(:key_type).find_by(key_types: { name: key_type_name.to_s })
  end

  def key_types_with_api_keys
    self.key_types.distinct
  end

  def confirmed?
    confirmed_at.present?
  end

  def pending_confirmation?
    !confirmed? && regular_user?
  end

  def generate_confirmation_token
    self.confirmation_token = SecureRandom.urlsafe_base64
    self.confirmation_sent_at = Time.current
  end

  # Authentication method display
  def auth_method
    if oauth_user?
      "#{provider.titleize} OAuth"
    else
      "Email/Password"
    end
  end

  private

  def password_required?
    regular_user? && (password_digest.blank? || password.present?)
  end

  def password_complexity
    return unless password.present?

    requirements = []
    requirements << "contain at least one lowercase letter" unless password.match?(/[a-z]/)
    requirements << "contain at least one uppercase letter" unless password.match?(/[A-Z]/)
    requirements << "contain at least one digit" unless password.match?(/\d/)
    requirements << "contain at least one special character" unless password.match?(/[!@#$%^&*(),.?":{}|<>]/)

    if requirements.any?
      errors.add(:password, "must #{requirements.join(', ')}")
    end
  end
end
