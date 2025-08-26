class KeyType < ApplicationRecord
  has_many :api_keys, dependent: :destroy
  
  validates :name, presence: true, uniqueness: true
end