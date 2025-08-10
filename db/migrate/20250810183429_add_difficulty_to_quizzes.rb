class AddDifficultyToQuizzes < ActiveRecord::Migration[8.0]
  def change
    add_column :quizzes, :difficulty, :integer, default: 1
  end
end
