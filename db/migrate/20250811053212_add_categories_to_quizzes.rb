class AddCategoriesToQuizzes < ActiveRecord::Migration[8.0]
  def change
    add_reference :quizzes, :category, null: false, foreign_key: true
  end
end
