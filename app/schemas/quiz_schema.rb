require "ruby_llm/schema"

class QuizSchema < RubyLLM::Schema
  string :title, description: "Quiz title"
  string :description, description: "Brief quiz description"

  array :questions do
    object do
      string :question_text, description: "The question text"
      integer :difficulty, description: "Difficulty level (1-3)"

      array :answers do
        object do
          string :text, description: "Answer text"
          boolean :is_correct, description: "Whether this answer is correct"
        end
      end
    end
  end
end
