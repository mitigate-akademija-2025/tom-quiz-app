class ChangeDescriptionToNotNull < ActiveRecord::Migration[8.0]
  def change
        change_column_null :quizzes, :description, false
  end
end
