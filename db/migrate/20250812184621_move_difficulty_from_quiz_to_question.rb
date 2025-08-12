class MoveDifficultyFromQuizToQuestion < ActiveRecord::Migration[8.0]
  def change
    add_column :questions, :difficulty, :integer, default: 1
    remove_column :quizzes, :difficulty, :integer
  end
end
