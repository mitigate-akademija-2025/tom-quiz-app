class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy
  has_many :quizzes, dependent: :destroy

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  encrypts :openai_api_key
  encrypts :gemini_api_key
end
