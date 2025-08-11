class Question < ApplicationRecord
  belongs_to :quiz
  has_many :answers, dependent: :destroy

  validates :quiz, presence: true
  validates :question_text, presence: true
  validates :question_type, presence: true
end
