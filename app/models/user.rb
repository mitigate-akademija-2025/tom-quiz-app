class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy
  has_many :quizzes, dependent: :destroy
  has_many :api_keys, dependent: :destroy
  has_many :key_types, through: :api_keys

  before_create :generate_confirmation_token
  normalizes :email_address, with: ->(e) { e.strip.downcase }
  validates :email_address, presence: true, uniqueness: { case_sensitive: false }

  validates :password, length: { minimum: 8, maximum: 128 },
            if: -> { password.present? }
  validates :password, confirmation: true, if: -> { password.present? }
  validate :password_complexity, if: -> { password.present? }

  # API key management methods
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

  def generate_confirmation_token
    self.confirmation_token = SecureRandom.urlsafe_base64
    self.confirmation_sent_at = Time.current
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
