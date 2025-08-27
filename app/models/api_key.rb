class ApiKey < ApplicationRecord
  belongs_to :user
  belongs_to :key_type

  encrypts :key

  validates :key, presence: true
  validates :key_type_id, uniqueness: { scope: :user_id, message: "already has a key of this type" }
end
