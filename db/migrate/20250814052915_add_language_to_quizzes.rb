class AddLanguageToQuizzes < ActiveRecord::Migration[8.0]
  def change
    add_column :quizzes, :language, :string
  end
end
