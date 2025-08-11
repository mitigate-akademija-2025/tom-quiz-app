class Question < ApplicationRecord
  belongs_to :quiz
  validates :question_text, presence: true
  validates :question_type, presence: true
end
