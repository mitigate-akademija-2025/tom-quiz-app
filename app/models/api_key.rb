class ApiKey < ApplicationRecord
  # Associations
  belongs_to :user
  belongs_to :key_type
  
  # Encryption
  encrypts :key

  # Validations
  validates :key, presence: true
  validates :key_type_id, uniqueness: { scope: :user_id, message: "already has a key of this type" }
end