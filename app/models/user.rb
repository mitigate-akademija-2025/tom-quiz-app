class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy
  has_many :quizzes, dependent: :destroy
  has_many :api_keys, dependent: :destroy

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  def api_key_for(key_type_name)
    api_keys.includes(:key_type).find_by(key_types: { name: key_type_name.to_s })
  end
end
