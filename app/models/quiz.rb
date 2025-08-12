class Quiz < ApplicationRecord
  belongs_to :category
  has_many :questions, dependent: :destroy
  validates :title, presence: true
  validates :description, presence: true
end
