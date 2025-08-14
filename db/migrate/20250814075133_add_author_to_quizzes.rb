class AddAuthorToQuizzes < ActiveRecord::Migration[8.0]
  def change
    add_column :quizzes, :author, :string
  end
end
