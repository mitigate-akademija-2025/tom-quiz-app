class Quiz < ApplicationRecord
  belongs_to :category
  belongs_to :user
  has_many :questions, dependent: :destroy
  validates :title, presence: true
  validates :description, presence: true
  belongs_to :user, optional: true
end
