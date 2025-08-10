class Quiz < ApplicationRecord
  validates :title, presence: true
  validates :description, presence: true
  validates :difficulty, presence: true, inclusion: { in: 1..4 }

  # Difficulty constants
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