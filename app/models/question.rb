class Question < ApplicationRecord
  belongs_to :quiz
  has_many :answers, dependent: :destroy

  validates :quiz, presence: true
  validates :question_text, presence: true
  validates :question_type, presence: true
  validates :question_type, inclusion: { in: %w[multiple_choice true_false short_answer] }
  validates :difficulty, presence: true, inclusion: { in: 1..4 }

  DIFFICULTIES = {
    1 => "Easy",
    2 => "Medium",
    3 => "Hard",
    4 => "Impossible"
  }.freeze

  def difficulty_name
    DIFFICULTIES[difficulty]
  end
end
